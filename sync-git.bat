@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-git.ps1" %*
pause
