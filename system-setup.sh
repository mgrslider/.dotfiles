#!/bin/bash
set -euo pipefail

MARKER="$HOME/.system_setup"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
else
    echo "Nie można wykryć dystrybucji"; exit 1
fi

step1_packages() {
    echo "==> [1/4] Instalacja pakietów"
    if [ "$DISTRO" = "arch" ]; then
        PACKAGES=(
            snapper snap-pac base-devel
            i3-wm i3blocks i3lock i3status
            git vim neovim ghostty
            unzip curl gnupg rsync htop
            pv tar fzf stow docker
            rofi feh redshift maim xclip
            xdotool ddcutil lm_sensors smartmontools
            openvpn networkmanager network-manager-applet
            firefox thunderbird keepassxc nautilus
            rclone pavucontrol wireplumber
            pipewire pipewire-pulse pipewire-alsa 
            xorg-xinit xorg-server
            bash-completion scrcpy starship
            tree-sitter tree-sitter-cli
            ttf-nerd-fonts-symbols
        )
        sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
        sudo pacman -S --needed --noconfirm libreoffice-still
        sudo systemctl enable NetworkManager
        sudo localectl set-keymap pl
        sudo systemctl enable --now docker.service
        sudo usermod -aG docker $(whoami)
    fi
    if [ "$DISTRO" = "fedora" ]; then
        sudo dnf copr enable -y scottames/ghostty
        sudo dnf copr enable -y atim/starship
        sudo dnf copr enable -y zeno/scrcpy
        PACKAGES=(
            i3 i3blocks git vim neovim ghostty
            unzip curl gnupg gnupg2 tar fzf stow
            rofi feh redshift maim xclip
            xdotool ddcutil lm_sensors smartmontools
            openvpn firefox thunderbird
            libreoffice keepassxc nautilus
            rclone pipewire pipewire-pulse
            pipewire-alsa wireplumber pavucontrol
            steam xorg-x11-xinit xorg-x11-server-Xorg
            NetworkManager NetworkManager-tui blueman bluez
            bash-completion scrcpy starship
        )
        sudo dnf install -y "${PACKAGES[@]}"
    fi
    if [ "$DISTRO" = "debian" ]; then
        sudo apt update
        sudo apt install -y \
            ghostty i3 i3blocks git vim neovim stow fzf \
            unzip curl gnupg rsync htop \
            rofi feh redshift maim xclip \
            xdotool ddcutil lm-sensors smartmontools network-manager \
            network-manager-gnome network-manager-openvpn openvpn \
            firefox-esr thunderbird \
            libreoffice keepassxc nautilus \
            rclone pipewire pipewire-pulse \
            pipewire-alsa wireplumber pavucontrol \
            bash-completion xinit scrcpy
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y contrib non-free non-free-firmware
        sudo dpkg --add-architecture i386
        sudo apt update
        sudo apt install -y nvidia-driver nvidia-settings
        sudo apt install -y steam-installer
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
}

step2_fetch_dotfiles() {
    echo "==> [2/4] Pobieranie dotfiles"
    if [ -d "$HOME/.dotfiles" ]; then
        git -C "$HOME/.dotfiles" pull --ff-only
    else
        git clone https://github.com/mgrslider/.dotfiles.git "$HOME/.dotfiles"
    fi
}

step3_install_dotfiles() {
    echo "==> [3/4] Instalacja dotfiles"
    cd "$HOME/.dotfiles"
    ./update_stow.sh
    cd "$HOME"
}

step4_login_fixes() {
    echo "==> [4/4] Poprawki do logowania"
    CURRENT_DM=$(basename "$(readlink -f /etc/systemd/system/display-manager.service)" .service 2>/dev/null || true)
    if [ -n "$CURRENT_DM" ] && [ "$CURRENT_DM" != "display-manager" ]; then
        sudo systemctl disable "$CURRENT_DM"
    fi
    sudo systemctl set-default multi-user.target
    echo "exec i3" > "$HOME/.xinitrc"
}

run_all() {
    if [ -f "$MARKER" ]; then
        echo "Skrypt już wykonany. Usuń $MARKER aby powtórzyć, lub uruchom pojedynczy krok: $0 <1|2|3|4>"
        exit 0
    fi
    step1_packages
    step2_fetch_dotfiles
    step3_install_dotfiles
    step4_login_fixes
    touch "$MARKER"
    echo "==> Gotowe. Zalecany reboot."
}

case "${1:-all}" in
    1) step1_packages ;;
    2) step2_fetch_dotfiles ;;
    3) step3_install_dotfiles ;;
    4) step4_login_fixes ;;
    all) run_all ;;
    *) echo "Użycie: $0 [1|2|3|4|all]"; exit 1 ;;
esac
