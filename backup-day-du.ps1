# Backup DAY DU (CA .git = ca lich su commit) cua MOI du an trong D:\github len Google Drive.
# Dung:  powershell -ExecutionPolicy Bypass -File .\backup-day-du.ps1            (tat ca du an)
#        powershell -ExecutionPolicy Bypass -File .\backup-day-du.ps1 -Project chiatien
# Ket qua: G:\My Drive\github-backup\<du-an>\day-du\<du-an>-day-du-<ngay-gio>.zip
#   - Bao gom .git, KHONG gom tai_lieu va node_modules (tai lieu da co ban sao rieng tren Drive)
#   - Du an = moi thu muc con cua D:\github co thu muc .git (tu dong, them du an moi khong can sua script)
#   - Giu 6 ban moi nhat moi du an. Khoi phuc: giai nen zip ra thu muc moi, vao do chay git status.
#   - Script khong doc/ghi bi mat nao. Zip nam tren Drive RIENG TU, khong dua vao repo.
#   - -MinDays N: bo qua du an nao da co ban day-du trong N ngay gan day (lich tu dong dung -MinDays 28)
#   - Ghi nhat ky moi lan chay vao G:\My Drive\github-backup\backup-log.txt
param([string]$Project = "", [int]$MinDays = 0)

$root = Split-Path $PSScriptRoot -Parent          # D:\github
$gd   = 'G:\My Drive\github-backup'
$log  = Join-Path $gd 'backup-log.txt'
function LogLine($s) { try { Add-Content -LiteralPath $log -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm') + '  ' + $s) } catch {} }
if (-not (Test-Path 'G:\My Drive')) { Write-Host "LOI: khong thay G:\My Drive (Google Drive chua chay). Dung lai, khong backup." -ForegroundColor Red; exit 1 }

$projs = Get-ChildItem -LiteralPath $root -Directory | Where-Object { (Test-Path -LiteralPath (Join-Path $_.FullName '.git')) -and ($Project -eq "" -or $_.Name -eq $Project) }
if (-not $projs) { Write-Host "Khong co du an nao de backup." -ForegroundColor Yellow; exit 1 }

Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach ($p in $projs) {
    $dest = Join-Path $gd (Join-Path $p.Name 'day-du')
    if (-not (Test-Path -LiteralPath $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
    if ($MinDays -gt 0) {
        $last = Get-ChildItem -LiteralPath $dest -Filter *.zip -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($last -and ((Get-Date) - $last.LastWriteTime).TotalDays -lt $MinDays) { Write-Host ($p.Name + ": con moi (" + $last.Name + "), bo qua"); LogLine ($p.Name + ': bo qua (ban gan nhat con moi)'); continue }
    }
    $zip = Join-Path $dest ($p.Name + '-day-du-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.zip')
    $tmp = Join-Path $env:TEMP ('gh-full-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmp | Out-Null
    robocopy $p.FullName $tmp /E /XD 'tai_lieu' 'node_modules' /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    # CreateFromDirectory (khong dung Compress-Archive: no bo qua thu muc an nhu .git)
    [IO.Compression.ZipFile]::CreateFromDirectory($tmp, $zip, [IO.Compression.CompressionLevel]::Optimal, $false)
    Remove-Item -Recurse -Force $tmp
    # Kiem tra zip doc lai duoc va co .git
    $z = [IO.Compression.ZipFile]::OpenRead($zip)
    $n = $z.Entries.Count
    $hasGit = @($z.Entries | Where-Object { $_.FullName -like '.git/*' -or $_.FullName -like '.git\*' }).Count
    $z.Dispose()
    $mb = [math]::Round((Get-Item -LiteralPath $zip).Length / 1MB, 1)
    $ok = ($n -gt 0 -and $hasGit -gt 0)
    $color = 'Green'; if (-not $ok) { $color = 'Red' }
    Write-Host ("{0}: {1} ({2} MB, {3} muc, {4} muc .git) -> {5}" -f $p.Name, $zip, $mb, $n, $hasGit, $(if ($ok) { 'OK' } else { 'LOI: zip thieu .git' })) -ForegroundColor $color
    LogLine ($p.Name + ': ' + $(if ($ok) { 'OK' } else { 'LOI zip thieu .git' }) + ' ' + (Split-Path $zip -Leaf) + ' ' + $mb + ' MB')
    if ($ok) { Get-ChildItem -LiteralPath $dest -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -Skip 6 | Remove-Item -Force }
}
