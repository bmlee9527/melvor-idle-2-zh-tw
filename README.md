# Melvor Idle 2 繁體中文翻譯（非官方）

這是 Steam 上 **Melvor Idle 2** 的玩家自製繁體中文翻譯。不修改遊戲本體，裝上後在遊戲的語言設定裡就能在「繁體中文」和英文之間切換，英文原版完整保留。

> ⚠️ 本翻譯為**非官方**玩家作品，與 Games By Malcs 無關。遊戲文字版權屬於原開發者，請勿用於商業用途。

- 適用版本：Melvor Idle 2 `v0.11.7-alpha`（Steam 搶先體驗版，Windows / Mac）
- 翻譯條目：約 14,000 條（介面、物品、技能、主線劇情、戰鬥說明等）

## 安裝方式（Windows）

1. 到 [Releases](../../releases/latest) 下載最新的 `Melvor2-zh_TW-*.zip`。
2. 在 Steam 收藏庫對遊戲按右鍵 → **管理** → **瀏覽本機檔案**，開啟遊戲資料夾（裡面有 `Melvor2.exe`）。
3. 把 zip 裡的 `override.cfg` 和 `mod` 資料夾解壓縮到這個資料夾，放好後長這樣：

   ```
   Melvor2.exe
   override.cfg
   mod\
       zh_TW.po
       zh_TW_patch.gd
   data_GamesByMalcs.Melvor2_windows_x86_64\
   ```

4. 從 Steam 啟動遊戲，在**設定 → 語言**選擇「繁體中文」。

> 系統語言是繁體中文的話，第一次啟動通常會自動選上繁體中文。遊戲執行中安裝的話，要完全關閉遊戲後再開才會生效。

## 切換語言

在遊戲的語言設定裡選「繁體中文」或「English」即可，選擇會被遊戲記住。選英文時就是原版，翻譯不會有任何作用。

## 移除方式

刪除遊戲資料夾裡的 `override.cfg` 和 `mod` 資料夾，重開遊戲即可。

## 從試玩版升級

- 試玩版的翻譯裝在 `%APPDATA%\Games By Malcs\Melvor Idle 2\`（`zh_TW.po`、`zh_TW_patch.gd`），正式版不會再讀取，可以直接刪除。
- 試玩版的 `install.bat` / `uninstall.bat` 已不再需要。

## Mac 安裝方式

> Mac 版沿用試玩版確認可用的做法，但正式版尚未在 Mac 上測試。遇到問題歡迎到 [Issues](../../issues) 回報。

1. 下載 Release 的 zip 並解壓縮（放在哪裡都可以，`mod` 資料夾要和腳本放在一起）。
2. 打開「終端機」，輸入 `bash `（後面有一個空格），把 `install-mac.command` 拖進視窗，按 Enter。
3. 腳本會先在 Steam 預設位置找遊戲。找不到的話，會請你把遊戲的 `.app` 拖進視窗。
4. 重新啟動遊戲，在語言設定選擇「繁體中文」。

移除時用同樣方式執行 `uninstall-mac.command`。如果 macOS 顯示遊戲「已損毀」或無法打開，請執行移除腳本，或在 Steam 對遊戲按右鍵 → 內容 → 已安裝檔案 →「驗證遊戲檔案完整性」。

## 運作原理

遊戲使用 Godot 引擎的翻譯系統，語言選單會列出所有已載入的語言。

- `override.cfg`：Godot 會讀取遊戲資料夾裡的這個檔案。它讓遊戲額外載入 `mod/zh_TW.po`（語系 `zh_TW`，所以語言選單會出現「繁體中文」），並在啟動時執行 `mod/zh_TW_patch.gd`。
- `zh_TW.po`：翻譯檔。
- `zh_TW_patch.gd`：有些文字是遊戲程式直接顯示原文、沒經過翻譯系統（例如商店說明、閃避列表的 Stab / Slash、「10 minutes」）。這個小腳本只在語言為繁體中文時動作，用翻譯檔的內容把畫面上的這些英文換成中文；切回英文時會還原。

因為只是額外放檔案，不會動到 `Melvor2.exe` 或存檔。

## 翻譯來源

- 試玩版時期的翻譯（AI 協助翻譯初稿，再人工修正）。
- 正式版新增的內容，大部分改編自遊戲內附、但尚未開放選用的官方簡體中文翻譯：用 [OpenCC](https://github.com/BYVoid/OpenCC) 轉為台灣正體用語，再統一成本翻譯的用詞，例如 Agility 一律為「敏捷」。人名、地名採用官方簡中的音譯。
- 官方英文清單漏掉的少數文字另外翻譯。

## 已知問題

- 少數由遊戲程式拼出來、混著圖示和顏色的文字可能仍是英文。
- 遊戲用程式拼出來的純英文句子換成中文後，可能失去原本的顏色。
- 在遊戲中切換語言時，遊戲記錄檔會出現一筆「顯示設定」下拉選單的錯誤。這是遊戲本身的問題，切換任何語言都會發生，不影響使用。
- 想找出還沒翻譯的文字：把 `mod/zh_TW_patch.gd` 開頭的 `LOG_UNTRANSLATED` 改成 `true`，玩一陣子後，`%APPDATA%\Games By Malcs\Melvor Idle 2\zh_TW_untranslated.txt` 會列出畫面上仍是英文的文字。
- 遊戲仍在搶先體驗階段，更新後新增的文字不會有翻譯，需要等這裡更新。

## 回報與貢獻

發現翻譯錯誤或漏翻？歡迎：

- 開一個 [Issue](../../issues)，附上截圖或原文與建議譯文。
- 直接修改 `release/mod/zh_TW.po` 並發 Pull Request。`.po` 是純文字格式，每條是 `msgid "英文原文"` 加 `msgstr "中文翻譯"`。修改時請保留 `{0}`、`{Value:...}` 這類大括號佔位符、`[color=...]`、`[b]` 等標籤，以及 `[Player Name]`、`[Companion Name]`，只改中文內容。

## 檔案說明

| 檔案 | 說明 |
| --- | --- |
| `release/override.cfg` | 讓遊戲載入翻譯與腳本的設定檔（Windows） |
| `release/mod/zh_TW.po` | 翻譯檔 |
| `release/mod/zh_TW_patch.gd` | 執行期文字替換腳本（處理翻譯檔管不到的文字） |
| `release/install-mac.command` | Mac 安裝腳本 |
| `release/uninstall-mac.command` | Mac 移除腳本 |
