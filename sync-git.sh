#!/bin/bash
# Dong bo git (Mac/Linux): commit -> pull --rebase -> push
# Dung:  bash ./sync-git.sh                      (message tu dong theo thoi gian)
#        bash ./sync-git.sh "noi dung commit"    (message tuy chinh)
# Chi chay SAU KHI chu repo dong y push.
cd "$(dirname "$0")" || exit 1

MSG="$1"
REMOTE="origin"

fail() { echo "LOI: $1"; exit 1; }

command -v git >/dev/null || fail "Chua cai git."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Thu muc nay chua phai git repo."

BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Nhanh: $BRANCH"

# 1. Commit thay doi local (neu co)
if [ -n "$(git status --porcelain)" ]; then
  [ -z "$MSG" ] && MSG="Auto sync $(date '+%Y-%m-%d %H:%M:%S')"
  git add -A
  git commit -m "$MSG" || fail "Commit that bai."
  echo "Da commit: $MSG"
else
  echo "Khong co thay doi can commit."
fi

git remote | grep -qx "$REMOTE" || { echo "Chua co remote '$REMOTE' - chi commit local."; exit 0; }

# 2. Lay thay doi tu remote
git fetch "$REMOTE" || fail "Fetch that bai (kiem tra mang/dang nhap GitHub)."
if git rev-parse --verify "$REMOTE/$BRANCH" >/dev/null 2>&1; then
  git pull --rebase "$REMOTE" "$BRANCH" || fail "Pull/rebase xung dot. Xu ly xung dot, 'git rebase --continue' roi chay lai."
fi

# 3. Day len remote
git push -u "$REMOTE" "$BRANCH" || fail "Push that bai."
echo "Dong bo xong."
