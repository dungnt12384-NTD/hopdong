# Rollback ban web that: hoan tac 1 commit bang "git revert" roi push (khong xoa lich su, co the lam lai).
# Dung:  .\quay-lai.ps1                 (hoan tac commit moi nhat)
#        .\quay-lai.ps1 -Commit 587ac10 (hoan tac commit cu the)
param([string]$Commit = "HEAD")

Set-Location -Path $PSScriptRoot
function Fail($text) { Write-Host "LOI: $text" -ForegroundColor Red; exit 1 }

# Tim git (may ban: git cua GitHub Desktop, chua co trong PATH)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    $g = Get-ChildItem "$env:LOCALAPPDATA\GitHubDesktop\app-*\resources\app\git\cmd\git.exe" -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1
    if (-not $g) { Fail "Khong tim thay git." }
    $env:PATH = (Split-Path $g.FullName) + ';' + $env:PATH
}

if (git status --porcelain) { Fail "Dang co thay doi chua commit. Xu ly (commit hoac giai nen backup) truoc khi quay lai." }

Write-Host "Se hoan tac commit:" -ForegroundColor Cyan
git log -1 --oneline $Commit
if ($LASTEXITCODE -ne 0) { Fail "Khong tim thay commit '$Commit'." }

git pull --rebase origin main
if ($LASTEXITCODE -ne 0) { Fail "Pull that bai." }

git revert --no-edit $Commit
if ($LASTEXITCODE -ne 0) { Fail "Revert bi xung dot. Chay 'git revert --abort' roi bao Claude xu ly." }

git push origin main
if ($LASTEXITCODE -ne 0) { Fail "Push that bai." }

Write-Host "Da quay lai. Web that cap nhat sau 1-2 phut (Ctrl+Shift+R de tai lai)." -ForegroundColor Green
git log --oneline -3
