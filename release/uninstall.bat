@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
echo Melvor Idle 2 Demo - 繁體中文翻譯 移除程式
echo.
set "DEST=%APPDATA%\Games By Malcs\Melvor Idle 2"
if exist "%DEST%\zh_TW.po" del /q "%DEST%\zh_TW.po"
if exist "override.cfg" del /q "override.cfg"
echo 已移除翻譯，重新啟動遊戲即恢復英文。
echo 剩下的 zh_TW.po、install.bat、uninstall.bat 可自行刪除。
echo.
pause
