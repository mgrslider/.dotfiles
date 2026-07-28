#!/bin/bash

# --- Backup + Stow ---
STOW_FOLDERS="$(find ./ -maxdepth 1 -mindepth 1 -type d -not -path '*/.*' | tr -d './' | paste -sd,)"

for folder in $(echo "$STOW_FOLDERS" | sed "s;,; ;g"); do
    [ "$folder" = "bash" ] && continue
    [ "$folder" = "install-scripts" ] && continue
    stow --simulate "$folder" 2>&1 | grep "existing target" | \
        sed "s/.*over existing target //" | sed "s/ since.*//" | \
        while read target; do
            if [ -e "$HOME/$target" ] && [ ! -L "$HOME/$target" ]; then
                echo "Backup: $HOME/$target -> $HOME/org_back_$(basename $target)"
                mv "$HOME/$target" "$HOME/org_back_$(basename $target)"
            fi
        done || true
    stow --simulate "$folder" 2>&1 | grep "existing target" | \
        sed "s/.*over existing target //" | sed "s/ since.*//" | \
        while read target; do
            rm -rf "$HOME/$target"
        done || true
    stow -D "$folder" 2>/dev/null || true
    stow "$folder"
done
