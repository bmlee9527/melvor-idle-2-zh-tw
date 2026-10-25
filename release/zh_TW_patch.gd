extends Node
# Melvor Idle 2 Demo 繁體中文翻譯 - 執行期文字替換
# 遊戲有些文字是程式直接顯示原文、沒經過翻譯系統，翻譯檔管不到。
# 這個腳本在每次畫面繪製前檢查 Label / RichTextLabel / Button 的文字，
# 能在翻譯檔裡找到對應中文的就換掉，並處理數字樣板、時間單位、逗號列表等格式。

# 設成 true 會把仍是英文的文字記到 user://zh_TW_untranslated.txt，方便補翻譯
const LOG_UNTRANSLATED := false
const LOG_PATH := "user://zh_TW_untranslated.txt"
const PO_PATH := "user://zh_TW.po"
# 除錯用：記錄每段英文文字的節點類型與替換結果
const DEBUG := false
const DEBUG_PATH := "user://zh_TW_debug.txt"
const CACHE_LIMIT := 20000

const UNITS := {
	"day": "天", "days": "天",
	"hour": "小時", "hours": "小時",
	"minute": "分鐘", "minutes": "分鐘",
	"second": "秒", "seconds": "秒",
}
# 中英混合的句子裡直接替換的片語
const PHRASES := {
	"less than ": "不到 ",
}

# 每幀檢查全部約 1,800 個元件太花時間，所以分三種：
# 新出現的下一幀立刻處理；被遊戲改回英文過的（計時器等）每幀檢查；其餘輪流檢查，每幀 1/8
const COLD_SLICES := 8
var _nodes := {}      # instance_id -> Control
var _fresh := []      # 剛出現、還沒檢查過的 instance_id
var _cold := []       # 輪流檢查的 instance_id
var _cold_pos := 0
var _hot := {}        # 每幀檢查的 instance_id
var _sets := {}       # instance_id -> 被腳本改寫的次數
var _last := {}       # instance_id -> 上次看到（或寫入）的文字
var _cache := {}      # 原文 -> 替換結果
var _seen := {}
var _templates := {}  # 關鍵字 -> [{re, tokens, dst}]
var _unit_re := RegEx.new()
var _latin_re := RegEx.new()
var _word_re := RegEx.new()
var _run_re := RegEx.new()
var _tag_re := RegEx.new()
var _cjk_re := RegEx.new()
var _ph_re := RegEx.new()
var _log: FileAccess
var _dbg: FileAccess
var _dbg_seen := {}
var _dbg_usec := 0
var _dbg_frames := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_unit_re.compile("(\\d+(?:[.,]\\d+)?) ?(days?|hours?|minutes?|seconds?)\\b")
	_latin_re.compile("[A-Za-z]{3,}")
	_word_re.compile("[A-Za-z]{3,}")
	_run_re.compile("[A-Za-z][A-Za-z']*(?: [A-Za-z][A-Za-z']*)*")
	_tag_re.compile("\\[img[^\\]]*\\][^\\[]*\\[/img\\]|\\[[^\\]]*\\]")
	_cjk_re.compile("[\\x{4e00}-\\x{9fff}]")
	_ph_re.compile("\\{[^{}]+\\}")
	_load_templates()
	if LOG_UNTRANSLATED:
		_log = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if DEBUG:
		_dbg = FileAccess.open(DEBUG_PATH, FileAccess.WRITE)
	get_tree().node_added.connect(_track)
	_track_tree(get_tree().root)
	# 排在所有節點的 _process 之後執行：遊戲每幀重設文字後立刻換掉，
	# 重繪排程還來得及在同一幀畫出中文（frame_pre_draw 太晚，會一直顯示英文）
	process_priority = 1 << 30


func _process(_delta: float) -> void:
	if not DEBUG:
		_refresh()
		return
	var t0 := Time.get_ticks_usec()
	_refresh()
	_dbg_usec += Time.get_ticks_usec() - t0
	_dbg_frames += 1
	if _dbg_frames == 600 and _dbg:
		_dbg.store_line("#perf %d nodes (%d hot), %.3f ms/frame, %d fps" % [_nodes.size(), _hot.size(), _dbg_usec / 600000.0, Engine.get_frames_per_second()])
		_dbg.flush()
		_dbg_frames = 0
		_dbg_usec = 0


func _track_tree(n: Node) -> void:
	_track(n)
	for c in n.get_children():
		_track_tree(c)


func _track(n: Node) -> void:
	if n is Label or n is RichTextLabel or n is Button:
		var id := n.get_instance_id()
		if not _nodes.has(id):
			_nodes[id] = n
			_fresh.append(id)


func _refresh() -> void:
	for id in _fresh:
		_check(id)
	_cold.append_array(_fresh)
	_fresh.clear()
	for id in _hot.keys():
		_check(id)
	var batch := ceili(_cold.size() / float(COLD_SLICES))
	for i in batch:
		if _cold.is_empty():
			break
		if _cold_pos >= _cold.size():
			_cold_pos = 0
		if _check(_cold[_cold_pos]):
			_cold_pos += 1
		else:
			_cold.remove_at(_cold_pos)


# 檢查並替換一個元件的文字；元件已被釋放時回傳 false
func _check(id: int) -> bool:
	var n = _nodes.get(id)
	if n == null or not is_instance_valid(n):
		_nodes.erase(id)
		_last.erase(id)
		_hot.erase(id)
		_sets.erase(id)
		return false
	var s: String = n.text
	# 遊戲用 add_text() 等方法拼出來的富文字，text 屬性是空的，要讀解析後的文字
	var built := false
	if s == "":
		if not (n is RichTextLabel) or not n.is_visible_in_tree():
			return true
		built = true
		s = n.get_parsed_text()
	if s == _last.get(id, ""):
		return true
	# 先比對文字（便宜），有變才檢查是否可見；隱藏的元件等顯示出來再處理
	if not built and not n.is_visible_in_tree():
		return true
	var t := s
	# 拼出來的富文字只能整段重寫，會失去原本的圖示和顏色，所以只處理不含中文的短句
	if not built or (s.length() < 100 and not _cjk_re.search(s)):
		t = _convert(s)
	if DEBUG and _dbg and not _dbg_seen.has(s) and _latin_re.search(s):
		_dbg_seen[s] = true
		_dbg.store_line("%s|%s|%s|%s => %s" % [n.get_class(), n.can_auto_translate(), built, s.c_escape(), t.c_escape()])
		_dbg.flush()
	if t != s:
		if built:
			n.clear()
			n.append_text(t)
		else:
			n.text = t
		# 改寫過又被遊戲改回去，代表它會一直更新，之後每幀檢查
		var c: int = _sets.get(id, 0) + 1
		_sets[id] = c
		if c >= 2:
			_hot[id] = true
	_last[id] = t
	return true


func _convert(s: String) -> String:
	var key := s
	if _cache.has(key):
		return _cache[key]
	var t := _translate(s)
	if _cache.size() > CACHE_LIMIT:
		_cache.clear()
	_cache[key] = t
	if LOG_UNTRANSLATED and _log and t == s and _tr(s) == s and not _seen.has(s) and _latin_re.search(s):
		_seen[s] = true
		_log.store_line(s.c_escape())
		_log.flush()
	return t


func _translate(s: String) -> String:
	if s.is_empty() or not _latin_re.search(s):
		return s
	# 整句在翻譯檔裡
	# 有些節點標示會自動翻譯、畫面上卻仍是英文，所以一律直接換成中文
	var t := _tr(s)
	if t != s:
		return t
	# 前後有空白的情況
	var core := s.strip_edges()
	if core != s and _tr(core) != core:
		return s.replace(core, _tr(core))
	# 「Stab, Slash, Crush」這類逗號列表：每一項都有翻譯才換
	if ", " in s:
		var parts := s.split(", ")
		var out := PackedStringArray()
		for p in parts:
			var tp := _tr(p.strip_edges())
			if tp == p.strip_edges():
				out.clear()
				break
			out.append(tp)
		if out.size() == parts.size():
			return "、".join(out)
	# 翻譯檔裡帶 {0} 的樣板：「5 Available」對上「{0:N0} Available」
	t = _match_template(s)
	if t != s:
		return t
	# 短的英文詞組逐字翻譯：「Normal Resistance」→「普通抗性」，每個字都有翻譯才換
	if not _cjk_re.search(s) and s.count(" ") < 4 and _run_re.search(s) and _run_re.search(s).get_string() == s:
		var words := PackedStringArray()
		for w in s.split(" "):
			var tw := _tr(w)
			if tw == w:
				words.clear()
				break
			words.append(tw)
		if not words.is_empty():
			return "".join(words)
	var result := s
	# 中文句子裡夾著的英文名稱：「…後Rune Essence耗盡」
	if _cjk_re.search(s):
		result = _replace_runs(result)
		for p in PHRASES:
			result = result.replace(p, PHRASES[p])
	# 時間單位：「10 minutes」→「10 分鐘」
	for m in _unit_re.search_all(result):
		result = result.replace(m.get_string(), m.get_string(1) + " " + UNITS[m.get_string(2)])
	return result


func _tr(s: String) -> String:
	return String(TranslationServer.translate(s))


func _match_template(s: String) -> String:
	var tried := {}
	for wm in _word_re.search_all(s):
		var w := wm.get_string().to_lower()
		if tried.has(w) or not _templates.has(w):
			continue
		tried[w] = true
		for tpl in _templates[w]:
			var m: RegExMatch = tpl.re.search(s)
			if m == null:
				continue
			var out: String = tpl.dst
			for i in tpl.tokens.size():
				out = out.replace(tpl.tokens[i], _tr(m.get_string(i + 1)))
			return out
	return s


# 只替換 BBCode 標籤以外的部分，避免動到圖片路徑
func _replace_runs(s: String) -> String:
	var out := ""
	var pos := 0
	for m in _tag_re.search_all(s):
		out += _replace_runs_plain(s.substr(pos, m.get_start() - pos)) + m.get_string()
		pos = m.get_end()
	return out + _replace_runs_plain(s.substr(pos))


func _replace_runs_plain(s: String) -> String:
	var out := s
	for m in _run_re.search_all(s):
		var w := m.get_string()
		var t := _tr(w)
		if t != w:
			out = out.replace(w, t)
	return out


# 從翻譯檔讀出含 {…} 佔位符的條目，轉成正規表示式樣板
func _load_templates() -> void:
	var f := FileAccess.open(PO_PATH, FileAccess.READ)
	if f == null:
		return
	var cur := {}
	var field := ""
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line.begins_with("msgid_plural "):
			field = "msgid_plural"
			cur[field] = _unquote(line.substr(13))
		elif line.begins_with("msgid "):
			_add_template(cur)
			cur = {}
			field = "msgid"
			cur[field] = _unquote(line.substr(6))
		elif line.begins_with("msgstr[0] "):
			field = "msgstr"
			cur[field] = _unquote(line.substr(10))
		elif line.begins_with("msgstr "):
			field = "msgstr"
			cur[field] = _unquote(line.substr(7))
		elif line.begins_with("\"") and field != "":
			cur[field] += _unquote(line)
		else:
			field = ""
	_add_template(cur)


func _unquote(q: String) -> String:
	return q.substr(1, q.length() - 2).c_unescape()


func _add_template(e: Dictionary) -> void:
	if not e.has("msgid") or e.get("msgstr", "") == "":
		return
	_build_template(e.msgid, e.msgstr)
	if e.has("msgid_plural"):
		_build_template(e.msgid_plural, e.msgstr)


func _build_template(src: String, dst: String) -> void:
	if src.length() > 150 or not "{" in src:
		return
	var pattern := "^"
	var tokens := []
	var literal := ""
	var pos := 0
	for m in _ph_re.search_all(src):
		var lit := src.substr(pos, m.get_start() - pos)
		literal += lit + " "
		pattern += _escape(lit) + "(.+?)"
		tokens.append(m.get_string())
		pos = m.get_end()
	if tokens.is_empty():
		return
	var tail := src.substr(pos)
	literal += tail
	pattern += _escape(tail) + "$"
	for m in _ph_re.search_all(dst):
		if not tokens.has(m.get_string()):
			return
	# 用最長的英文字當索引，沒有英文字的樣板（如「{0}: {1}」）太籠統，不採用
	var key := ""
	for wm in _word_re.search_all(literal):
		if wm.get_string().length() > key.length():
			key = wm.get_string()
	if key == "":
		return
	var re := RegEx.new()
	if re.compile(pattern) != OK:
		return
	key = key.to_lower()
	if not _templates.has(key):
		_templates[key] = []
	_templates[key].append({"re": re, "tokens": tokens, "dst": dst})


func _escape(s: String) -> String:
	var out := ""
	for c in s:
		if c in "\\.^$|?*+()[]{}":
			out += "\\"
		out += c
	return out
