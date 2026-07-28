#!/bin/bash
set -euo pipefail

DOT_FILES="$HOME/.dotfiles"
cd "$DOT_FILES"


bash "./backup_and_stow.sh"

# --- Uruchom install-scripts ---
if [ -d "$DOT_FILES/install-scripts" ]; then
    echo ""
    echo "==> Uruchamiam install-scripts..."
    for script in "$DOT_FILES"/install-scripts/*.sh; do
        [ -f "$script" ] || continue
        echo "  -> $(basename $script)"
        bash "$script"
    done
fi

echo ""

i3-msg restart

echo "==> install.sh gotowe!"
