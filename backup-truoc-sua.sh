#!/bin/bash
# Backup 1 ban truoc moi lan sua doi (Mac/Linux), de rollback khi loi.
# Dung:  bash ./backup-truoc-sua.sh "mo-ta-ngan"
# Ket qua: ~/Library/CloudStorage/.../github-backup neu co Google Drive, neu khong thi <thu-muc-cha-cua-repo>/hopdong-backup
#   (NGOAI repo, khong bi push). Zip khong chua .git va tai_lieu.
# Co the dat bien GDRIVE_BACKUP de chi dinh thu muc sao luu tren Google Drive.
cd "$(dirname "$0")" || exit 1
REPO="$(pwd)"
NOTE=$(echo "${1:-backup}" | tr -c 'A-Za-z0-9_\n-' '-')
DEST="${GDRIVE_BACKUP:-$(dirname "$REPO")/hopdong-backup}"
mkdir -p "$DEST"
ZIP="$DEST/$(date '+%Y%m%d-%H%M%S')_${NOTE}.zip"

zip -rq "$ZIP" . -x ".git/*" "tai_lieu/*" || { echo "LOI: khong tao duoc zip (da cai 'zip' chua?)"; exit 1; }
echo "Da backup: $ZIP (commit $(git rev-parse --short HEAD 2>/dev/null))"

# Giu toi da 30 ban moi nhat
ls -1t "$DEST"/*.zip 2>/dev/null | tail -n +31 | while read -r f; do rm -f "$f"; done
