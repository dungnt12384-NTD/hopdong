# Dat lich tu dong chay backup-day-du.ps1 (Windows Task Scheduler), chay 1 lan de cai.
# Lich: moi Chu nhat 20:00 (bo lo thi chay ngay khi may bat lai); script chi thuc su backup khi ban gan nhat > 28 ngay (-MinDays 28)
#   => thuc te ~ moi thang 1 lan. Chay duoi tai khoan hien tai, khi da dang nhap Windows, khong can mat khau.
# Xem lai:  schtasks /Query /TN "BackupGitHubDayDu" /FO LIST      Go bo:  schtasks /Delete /TN "BackupGitHubDayDu" /F
$script = Join-Path $PSScriptRoot 'backup-day-du.ps1'
$arg    = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $script + '" -MinDays 28'
$action   = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arg
$trigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 20:00
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -TaskName 'BackupGitHubDayDu' -Action $action -Trigger $trigger -Settings $settings -Description 'Backup day du (co .git) cac du an D:\github len G:\My Drive\github-backup' -Force | Out-Null
Write-Host 'Da dat lich BackupGitHubDayDu (Chu nhat 20:00, backup thuc te moi ~28 ngay).' -ForegroundColor Green
