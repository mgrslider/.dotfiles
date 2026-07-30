#!/bin/bash
set -e

if ! command -v pv &>/dev/null; then
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

BACKUP_DIR=~/backup_export
rm -rdf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

find ~/.dotfiles -type f -name '*.tar.gpg' -delete 2>/dev/null || true

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

# Kopiowanie danych
cp ~/.my-git-credentials "$BACKUP_DIR/my-git-credentials"
cp -r ~/.ssh "$BACKUP_DIR/ssh"
chmod 700 "$BACKUP_DIR/ssh"
chmod 600 "$BACKUP_DIR/ssh/"* 2>/dev/null || true
chmod 644 "$BACKUP_DIR/ssh/"*.pub 2>/dev/null || true

sudo cp -r /etc/openvpn "$BACKUP_DIR/openvpn"
sudo chown -R "$USER:$USER" "$BACKUP_DIR/openvpn"

sudo cp /etc/hosts "$BACKUP_DIR/hosts"
sudo chown "$USER:$USER" "$BACKUP_DIR/hosts"
sudo grep -E '^\s*[^#].*\s(/work|/data|/backup)\s' /etc/fstab > "$BACKUP_DIR/fstab_snippet"
sudo chown "$USER:$USER" "$BACKUP_DIR/fstab_snippet"
sudo cp /etc/crypttab "$BACKUP_DIR/crypttab"
sudo chown "$USER:$USER" "$BACKUP_DIR/crypttab"
sudo cp -r /etc/luks-keys "$BACKUP_DIR/luks-keys"
sudo chown -R "$USER:$USER" "$BACKUP_DIR/luks-keys"

copy_item ~/.thunderbird "$BACKUP_DIR/thunderbird" "thunderbird"

# Pakowanie + szyfrowanie (AES-256)
read -s -p "Podaj hasło do archiwum: " PASS; echo
read -s -p "Podaj hasło do archiwum: " PASS2; echo
if [ "$PASS" != "$PASS2" ]; then
  echo "BŁĄD: Hasła się nie zgadzają"
  rm -rf "$BACKUP_DIR"
  exit 1
fi

SIZE=$(du -sb "$BACKUP_DIR" | cut -f1)
tar -c -C "$BACKUP_DIR" . \
  | pv -s "$SIZE" \
  | gpg --batch --yes --passphrase-fd 3 \
        --cipher-algo AES256 --symmetric \
        -o backup_$(date +%Y%m%d).tar.gpg 3<<<"$PASS"
unset PASS PASS2

rm -rf "$BACKUP_DIR"
echo "Gotowe: backup_$(date +%Y%m%d).tar.gpg"
echo "Nie zapomnij system-setup.sh"
