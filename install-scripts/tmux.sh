#!/bin/bash
# Instalacja tmux - zawsze najnowsza wersja
set -e

# Pobierz najnowszą wersję z GitHub API
TMUX_VERSION=$(curl -fsSL https://api.github.com/repos/tmux/tmux/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')

if [ -z "$TMUX_VERSION" ]; then
    echo "  -> BŁĄD: Nie można pobrać najnowszej wersji tmux"
    exit 1
fi

echo "  -> Najnowsza wersja tmux: $TMUX_VERSION"

if command -v tmux &>/dev/null; then
    CURRENT=$(tmux -V | awk '{print $2}' | tr -d 'a-z')
    LATEST=$(echo "$TMUX_VERSION" | tr -d 'a-z')
    if [ "$CURRENT" = "$LATEST" ]; then
        echo "  -> tmux $TMUX_VERSION już zainstalowany, pomijam"
        exit 0
    fi
fi

if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm tmux
elif command -v apt &>/dev/null; then
    echo "  -> Instaluję tmux $TMUX_VERSION z prebuilt..."
    TMUX_URL="https://github.com/tmux/tmux-builds/releases/download/v${TMUX_VERSION}/tmux-${TMUX_VERSION}-linux-x86_64.tar.gz"
    curl -fsSL "$TMUX_URL" -o /tmp/tmux.tar.gz
    tar -xzf /tmp/tmux.tar.gz -C /tmp
    sudo cp "/tmp/tmux-${TMUX_VERSION}-linux-x86_64/tmux" /usr/local/bin/tmux
    rm -rf /tmp/tmux.tar.gz "/tmp/tmux-${TMUX_VERSION}-linux-x86_64"
fi

echo "  -> $(tmux -V) zainstalowany"
