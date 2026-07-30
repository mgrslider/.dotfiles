#!/bin/bash
set -e

FILE="$1"
if [ -z "$FILE" ]; then
  echo "Użycie: ./restore.sh backup_XXXXXXXX.tar.gz.gpg"
  exit 1
fi

if ! command -v pv &>/dev/null || ! command -v gpg &>/dev/null || ! command -v tar &>/dev/null; then
  if command -v dnf &>/dev/null; then
    sudo dnf install -y pv gnupg2 tar
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y pv gnupg tar
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm pv gnupg tar
  else
    echo "Nieznany menedżer pakietów"; exit 1
  fi
fi

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

#git-credentials
cp "$RESTORE_DIR/my-git-credentials" ~/.my-git-credentials
chmod 600 ~/.my-git-credentials

# hosts
sudo cp "$RESTORE_DIR/hosts" /etc/hosts

sudo cp "$RESTORE_DIR/crypttab" /etc/crypttab
sudo tee -a /etc/fstab < "$RESTORE_DIR/fstab_snippet" > /dev/null

# weryfikacja fstab
sudo systemctl daemon-reload
sudo mount -a && echo "OK — montowanie działa." || echo "BŁĄD montowania — sprawdź $FSTAB!"

rm -rf "$RESTORE_DIR"
echo "Przywrócono."
