#!/bin/bash
# Melvor Idle 2 Demo 繁體中文翻譯 - macOS 移除腳本
# 用法：打開「終端機」，輸入 bash 加一個空格，把這個檔案拖進視窗後按 Enter。

echo "Melvor Idle 2 Demo - 繁體中文翻譯 移除程式（Mac）"
echo

GAME_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Melvor Idle 2 Demo"
APP=""
if [ -d "$GAME_DIR" ]; then
  APP="$(find "$GAME_DIR" -maxdepth 1 -name '*.app' -print -quit)"
fi
if [ -z "$APP" ]; then
  echo "在 Steam 預設位置找不到遊戲。請把遊戲的 .app 拖進這個視窗，然後按 Enter："
  read -r APP
  APP="$(printf '%s' "$APP" | sed -e 's/[[:space:]]*$//' -e "s/^'//" -e "s/'$//" -e 's/\\\(.\)/\1/g')"
  APP="${APP%/}"
fi

DEST="$HOME/Library/Application Support/Games By Malcs/Melvor Idle 2"
rm -f "$DEST/zh_TW.po" "$DEST/zh_TW_patch.gd" "$DEST/zh_TW_untranslated.txt" "$DEST/zh_TW_debug.txt"
if [ -d "$APP/Contents" ]; then
  rm -f "$APP/Contents/MacOS/override.cfg" "$APP/Contents/Resources/override.cfg"
fi

echo "已移除翻譯，重新啟動遊戲即恢復英文。"
echo "如果遊戲仍無法打開，請在 Steam 對遊戲按右鍵 > 內容 > 已安裝檔案 > 驗證遊戲檔案完整性。"
