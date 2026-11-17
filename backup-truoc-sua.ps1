# Backup 1 ban truoc moi lan sua doi, de rollback khi loi.
# Dung:  .\backup-truoc-sua.ps1 -Note "mo ta ngan"
# Ket qua: D:\github\hopdong-backup\<ngay-gio>_<note>.zip (nam NGOAI repo, khong bi push)
# Khoi phuc: giai nen file zip de len thu muc repo, hoac dung git checkout / git stash neu da commit.
param(
    [string]$Note = "backup"
)

$repo = $PSScriptRoot
$dest = Join-Path (Split-Path $repo -Parent) "hopdong-backup"
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

$safe = ($Note -replace '[^A-Za-z0-9_-]', '-')
$name = (Get-Date -Format "yyyyMMdd-HHmmss") + "_" + $safe + ".zip"
$zip  = Join-Path $dest $name

# Copy tam (bo .git) roi nen
$tmp = Join-Path $env:TEMP ("hopdong-bk-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp | Out-Null
robocopy $repo $tmp /E /XD ".git" /NFL /NDL /NJH /NJS /NP | Out-Null
Compress-Archive -Path (Join-Path $tmp "*") -DestinationPath $zip -Force
Remove-Item -Recurse -Force $tmp

# Ghi them commit hien tai de biet backup ung voi ban nao
$head = (git -C $repo rev-parse --short HEAD) 2>$null
Write-Host "Da backup: $zip (commit $head)" -ForegroundColor Green

# Giu toi da 30 ban backup moi nhat
Get-ChildItem $dest -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -Skip 30 | Remove-Item -Force
