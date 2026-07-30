#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# foldery stow: wszystkie katalogi poza ukrytymi i install-scripts
STOW_FOLDERS="$(find . -maxdepth 1 -mindepth 1 -type d \
    -not -path './.*' \
    -not -name 'install-scripts' \
    -printf '%f\n')"

for folder in $STOW_FOLDERS; do
    # znajdź kolidujące pliki (symulacja)
    conflicts="$(stow --simulate "$folder" 2>&1 \
        | grep 'existing target' \
        | sed 's/.*existing target //' | sed 's/ since.*//')"

    while IFS= read -r target; do
        [ -z "$target" ] && continue                 # guard: nie ruszaj pustych
        src="$HOME/$target"
        [ -e "$src" ] || continue
        [ -L "$src" ] && continue                    # symlink = już stowowane, pomiń

        # backup z zachowaniem struktury katalogów
        mkdir -p "$BACKUP_DIR/$(dirname "$target")"
        echo "Backup: $src -> $BACKUP_DIR/$target"
        mv "$src" "$BACKUP_DIR/$target"
    done <<< "$conflicts"

    stow -D "$folder" 2>/dev/null || true            # reset istniejących linków
    stow "$folder"
    echo "Stowed: $folder"
done

echo ""
echo "Backup oryginałów w: $BACKUP_DIR"

# --- Uruchom install-scripts ---
if [ -d "$DOTFILES_DIR/install-scripts" ]; then
    echo ""
    echo "==> Uruchamiam install-scripts..."
    for script in "$DOTFILES_DIR"/install-scripts/*.sh; do
        [ -f "$script" ] || continue
        echo "  -> $(basename $script)"
        bash "$script"
    done
fi

echo ""

i3-msg restart || true

echo "==> install.sh gotowe!"
