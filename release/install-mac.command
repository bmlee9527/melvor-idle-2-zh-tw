#!/bin/bash
# Melvor Idle 2 Demo 繁體中文翻譯 - macOS 安裝腳本
# 用法：打開「終端機」，輸入 bash 加一個空格，把這個檔案拖進視窗後按 Enter。

cd "$(dirname "$0")" || exit 1
echo "Melvor Idle 2 Demo - 繁體中文翻譯 安裝程式（Mac）"
echo

if [ ! -f "zh_TW.po" ] || [ ! -f "override.cfg" ]; then
  echo "[錯誤] 找不到 zh_TW.po 或 override.cfg，請確認和本檔案放在同一個資料夾。"
  exit 1
fi

# 尋找遊戲的 .app：先找 Steam 預設位置，找不到就請使用者拖曳
GAME_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Melvor Idle 2 Demo"
APP=""
if [ -d "$GAME_DIR" ]; then
  APP="$(find "$GAME_DIR" -maxdepth 1 -name '*.app' -print -quit)"
fi
if [ -z "$APP" ]; then
  echo "在 Steam 預設位置找不到遊戲。"
  echo "請在 Steam 對遊戲按右鍵 > 管理 > 瀏覽本機檔案，"
  echo "把遊戲的 .app 拖進這個視窗，然後按 Enter："
  read -r APP
  # 去掉拖曳時加上的尾端空白、引號和跳脫字元
  APP="$(printf '%s' "$APP" | sed -e 's/[[:space:]]*$//' -e "s/^'//" -e "s/'$//" -e 's/\\\(.\)/\1/g')"
  APP="${APP%/}"
fi
if [ ! -d "$APP/Contents" ]; then
  echo "[錯誤] 這不是有效的 .app：$APP"
  exit 1
fi

# 翻譯檔放到遊戲的使用者資料夾（user://）
DEST="$HOME/Library/Application Support/Games By Malcs/Melvor Idle 2"
mkdir -p "$DEST" && cp -f "zh_TW.po" "$DEST/zh_TW.po" || { echo "[錯誤] 複製翻譯檔失敗。"; exit 1; }

# override.cfg 兩個位置都放（已確認此做法在 Mac 上可用）
for d in "$APP/Contents/MacOS" "$APP/Contents/Resources"; do
  if [ -d "$d" ]; then
    cp -f "override.cfg" "$d/override.cfg" || echo "[警告] 無法寫入 $d"
  fi
done

echo "安裝完成！請完全關閉遊戲後重新啟動。"
echo "翻譯檔位置：$DEST/zh_TW.po"
echo
echo "如果 macOS 顯示遊戲「已損毀」或無法打開，請執行 uninstall-mac.command 移除，"
echo "並到 GitHub 回報，謝謝！"
