@echo off
setlocal
chcp 65001 >nul
set "AI_DIR=%~dp0"
cd /d "%AI_DIR%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%AI_DIR%Start-WhisperJAV.ps1"
if not "%errorlevel%"=="0" (
  echo [錯誤] WhisperJAV 啟動失敗。
  pause
  exit /b 1
)
