#!/bin/bash
set -e

FILE="$1"
if [ -z "$FILE" ]; then
  echo "Użycie: ./restore.sh backup_XXXXXXXX.tar.gz.gpg"
  exit 1
fi

command -v pv &>/dev/null || sudo pacman -S --needed --noconfirm sudo gnupg tar pv

copy_item() {
  local src=$1 dst=$2 label=$3
  [ -e "$src" ] || { echo "  -> $label: pomijam (brak $src)"; return 0; }
  local size=$(du -sb "$src" 2>/dev/null | cut -f1)
  echo "  -> $label ($(du -sh "$src" | cut -f1))"
  mkdir -p "$dst"                    # <-- to naprawia błąd
  tar -C "$(dirname "$src")" -cf - "$(basename "$src")" \
    | pv -s "$size" \
    | tar -C "$dst" -xf -
}

RESTORE_DIR=~/backup_restore
mkdir -p "$RESTORE_DIR"

read -s -p "Podaj hasło do archiwum: " PASS; echo
SIZE=$(stat -c%s "$FILE")
gpg --batch --yes --passphrase-fd 3 -d "$FILE" 3<<<"$PASS" \
  | pv -s "$SIZE" \
  | tar -x -C "$RESTORE_DIR"
unset PASS

# SSH
cp -r "$RESTORE_DIR/ssh" ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/* 2>/dev/null || true
chmod 644 ~/.ssh/*.pub 2>/dev/null || true

# OpenVPN
sudo cp -r "$RESTORE_DIR/openvpn" /etc/openvpn

# Thunderbird
copy_item "$RESTORE_DIR/thunderbird" ~/.thunderbird "thunderbird"

# hosts
sudo cp "$RESTORE_DIR/hosts" /etc/hosts

rm -rf "$RESTORE_DIR"
echo "Przywrócono."
