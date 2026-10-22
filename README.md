# Melvor Idle 2 Demo 繁體中文翻譯（非官方）

這是 Steam 上 **Melvor Idle 2 Demo** 的玩家自製繁體中文翻譯，不需要修改遊戲本體，裝上或移除只要幾秒鐘。

> ⚠️ 本翻譯為**非官方**玩家作品，與 Games By Malcs 無關。遊戲文字版權屬於原開發者，請勿用於商業用途。

- 適用版本：Melvor Idle 2 Demo `v0.11.2-alpha.4`（Windows / Steam）
- 翻譯條目：約 8,350 條（介面、物品、技能、任務對話、戰鬥說明等）

## 安裝方式

1. 到 [Releases](../../releases/latest) 下載最新的 `Melvor2-zh_TW-*.zip`。
2. 在 Steam 收藏庫對遊戲按右鍵 → **管理** → **瀏覽本機檔案**，開啟遊戲資料夾（裡面有 `Melvor2.exe`）。
3. 把 zip 裡的所有檔案解壓縮到這個資料夾。
4. 雙擊執行 `install.bat`。
5. 重新啟動遊戲即可看到中文。

> 遊戲執行中安裝的話，要完全關閉遊戲後再開才會生效。

### 手動安裝（不想執行 bat 的話）

1. 把 `override.cfg` 放進遊戲資料夾（與 `Melvor2.exe` 同一層）。
2. 把 `zh_TW.po` 複製到 `%APPDATA%\Games By Malcs\Melvor Idle 2\`（在檔案總管網址列貼上這個路徑即可開啟）。

## 移除方式

執行遊戲資料夾裡的 `uninstall.bat`，或手動刪除上面兩個檔案，重開遊戲就會恢復英文。

## 運作原理

遊戲使用 Godot 引擎的翻譯系統，但啟動時會強制把語系設為 `en_GB`。因此：

- `override.cfg`：Godot 會讀取遊戲資料夾裡的這個檔案，讓遊戲額外載入 `user://zh_TW.po`（也就是 `%APPDATA%\Games By Malcs\Melvor Idle 2\zh_TW.po`）。
- `zh_TW.po`：內容是中文，但語系標記為 `en_GB`，所以遊戲在「英式英文」模式下會套用它。

因為只是額外放檔案，不會動到 `Melvor2.exe` 或存檔，Steam 驗證檔案時也不會刪除它們。

## 已知問題

- 少數文字仍是英文，例如戰鬥面板閃避列表的 Stab / Slash、部分物品名稱（如「Herring」耗盡提示）、時間格式（「10 minutes」）。這些是遊戲程式直接顯示原文，沒有經過翻譯系統，翻譯檔無法處理。
- 部分地名、人名、草藥名保留英文原文（如 Azamire、Penril）。
- 遊戲仍在 alpha 階段，更新後新增的文字不會有翻譯。如果某次更新後遊戲不再強制 `en_GB`，翻譯會整個失效，需要把 `zh_TW.po` 開頭的 `Language: en_GB` 改回 `zh_TW`。
- 翻譯初稿由 AI 協助完成，可能有用詞不自然的地方。

## 回報與貢獻

發現翻譯錯誤或漏翻？歡迎：

- 開一個 [Issue](../../issues)，附上截圖或原文與建議譯文。
- 直接修改 `release/zh_TW.po` 並發 Pull Request。`.po` 是純文字格式，每條是 `msgid "英文原文"` 加 `msgstr "中文翻譯"`。修改時請保留 `{0}`、`{Value:...}` 這類大括號佔位符和 `[color=...]`、`[b]` 等標籤，只改中文內容。

## 檔案說明

| 檔案 | 說明 |
| --- | --- |
| `release/zh_TW.po` | 翻譯檔 |
| `release/override.cfg` | 讓遊戲載入翻譯的設定檔 |
| `release/install.bat` | 安裝程式（把翻譯檔複製到 AppData） |
| `release/uninstall.bat` | 移除程式 |
