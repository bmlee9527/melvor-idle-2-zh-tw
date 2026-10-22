@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
echo Melvor Idle 2 Demo - 繁體中文翻譯 安裝程式
echo.
if not exist "Melvor2.exe" goto notfound
if not exist "zh_TW.po" goto missing
if not exist "override.cfg" goto missing
set "DEST=%APPDATA%\Games By Malcs\Melvor Idle 2"
if not exist "%DEST%" mkdir "%DEST%"
copy /y "zh_TW.po" "%DEST%\zh_TW.po" >nul
if errorlevel 1 goto copyfail
echo 安裝完成！請完全關閉遊戲後重新啟動。
echo 翻譯檔位置：%DEST%\zh_TW.po
goto end

:notfound
echo [錯誤] 找不到 Melvor2.exe。
echo 請把所有檔案解壓縮到遊戲資料夾（與 Melvor2.exe 同一層）後再執行。
echo Steam 收藏庫：右鍵遊戲 ^> 管理 ^> 瀏覽本機檔案
goto end

:missing
echo [錯誤] 缺少 zh_TW.po 或 override.cfg，請重新解壓縮完整檔案。
goto end

:copyfail
echo [錯誤] 複製翻譯檔失敗。
goto end

:end
echo.
pause
