# Dong bo git: commit -> pull --rebase -> push
# Dung:  .\sync-git.ps1                      (commit message tu dong theo thoi gian)
#        .\sync-git.ps1 -Message "noi dung"  (commit message tuy chinh)
param(
    [string]$Message = "",
    [string]$Remote  = "origin"
)

Set-Location -Path $PSScriptRoot

function Fail($text) {
    Write-Host "LOI: $text" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Fail "Chua cai git." }

git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    Fail "Thu muc nay chua phai git repo. Chay: git init; git remote add origin <url>"
}

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$hasRemote = (git remote) -contains $Remote
Write-Host "Nhanh: $branch" -ForegroundColor Cyan

# 1. Commit thay doi local (neu co)
if (git status --porcelain) {
    if (-not $Message) { $Message = "Auto sync " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    git add -A
    git commit -m $Message
    if ($LASTEXITCODE -ne 0) { Fail "Commit that bai." }
    Write-Host "Da commit: $Message" -ForegroundColor Green
}
else {
    Write-Host "Khong co thay doi can commit."
}

if (-not $hasRemote) {
    Write-Host "Chua co remote '$Remote' - chi commit local." -ForegroundColor Yellow
    exit 0
}

# 2. Lay thay doi tu remote
git fetch $Remote
if ($LASTEXITCODE -ne 0) { Fail "Fetch that bai (kiem tra mang/dang nhap GitHub)." }

git rev-parse --verify "$Remote/$branch" *> $null
if ($LASTEXITCODE -eq 0) {
    git pull --rebase $Remote $branch
    if ($LASTEXITCODE -ne 0) {
        Fail "Pull/rebase xung dot. Xu ly xung dot, chay 'git rebase --continue' roi chay lai script."
    }
}

# 3. Day len remote
git push -u $Remote $branch
if ($LASTEXITCODE -ne 0) { Fail "Push that bai." }

Write-Host "Dong bo xong." -ForegroundColor Green
