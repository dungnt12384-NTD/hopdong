# Backup 1 ban truoc moi lan sua doi, de rollback khi loi.
# Dung:  .\backup-truoc-sua.ps1 -Note "mo ta ngan"
# Ket qua: G:\My Drive\github-backup\<ngay-gio>_<note>.zip (Google Drive, NGOAI repo, khong bi push)
#   - zip KHONG chua .git va tai_lieu (tai lieu hop dong that, nang)
#   - thu muc tai_lieu duoc copy them sang G:\My Drive\github-backup\tai_lieu (chi them/cap nhat, khong xoa)
#   - neu o G: khong san sang thi tam luu o D:\github\hopdong-backup va canh bao
# Khoi phuc: giai nen file zip de len thu muc repo, hoac dung git checkout / git stash neu da commit.
param(
    [string]$Note = "backup"
)

$repo = $PSScriptRoot
$dest = 'G:\My Drive\github-backup'
if (-not (Test-Path 'G:\My Drive')) {
    Write-Host "CANH BAO: khong thay G:\My Drive (Google Drive chua chay?). Tam luu o D:\github\hopdong-backup" -ForegroundColor Yellow
    $dest = Join-Path (Split-Path $repo -Parent) "hopdong-backup"
}
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

$safe = ($Note -replace '[^A-Za-z0-9_-]', '-')
$name = (Get-Date -Format "yyyyMMdd-HHmmss") + "_" + $safe + ".zip"
$zip  = Join-Path $dest $name

# Copy tam (bo .git va tai_lieu) roi nen
$tmp = Join-Path $env:TEMP ("hopdong-bk-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp | Out-Null
robocopy $repo $tmp /E /XD ".git" "tai_lieu" /NFL /NDL /NJH /NJS /NP | Out-Null
Compress-Archive -Path (Join-Path $tmp "*") -DestinationPath $zip -Force
Remove-Item -Recurse -Force $tmp

# Sao luu tai_lieu (chi them/cap nhat, khong bao gio xoa ben dich)
if (Test-Path (Join-Path $repo "tai_lieu")) {
    robocopy (Join-Path $repo "tai_lieu") (Join-Path $dest "tai_lieu") /E /XO /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
}

# Ghi them commit hien tai de biet backup ung voi ban nao
$head = (git -C $repo rev-parse --short HEAD) 2>$null
Write-Host "Da backup: $zip (commit $head)" -ForegroundColor Green

# Giu toi da 30 ban backup moi nhat
Get-ChildItem $dest -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -Skip 30 | Remove-Item -Force
