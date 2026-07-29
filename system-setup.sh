#!/bin/bash
set -e

MARKER="/mnt/.system_setup"
if [ -f "$MARKER" ]; then
    echo "Skrypt już został wykonany, jeżeli chcesz go wykonać jeszcze raz usuń $MARKER"
    exit 0
fi
touch "$MARKER"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
else
    echo "Nie można wykryć dystrybucji"
    exit 1
fi

echo "==> [1/4] Instalacja pakietów"


if [ "$DISTRO" = "fedora" ]; then
    # --- COPR: ghostty ---
    sudo dnf copr enable -y scottames/ghostty

    # --- RPM Fusion (nvidia, kodeki) ---
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # --- Sterownik nvidia ---
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-libs.i686

    # --- Grupa Development Tools (odpowiednik base-devel) ---
    sudo dnf group install -y "Development Tools"

    PACKAGES=(
        i3blocks git vim neovim ghostty stow fzf
        unzip curl gnupg rsync htop cmake
        ninja ccache golang python3 android-tools
        scrcpy rofi feh redshift starship maim xclip
        xdotool ddcutil lm_sensors smartmontools NetworkManager
        network-manager-applet NetworkManager-openvpn openvpn
        blueman bluez firefox thunderbird
        libreoffice keepassxc nautilus
        rclone pipewire pipewire-pulse
        pipewire-alsa wireplumber pavucontrol
        nvidia-settings bash-completion
        steam xorg-x11-xinit
    )

    sudo dnf install -y "${PACKAGES[@]}"
fi
if [ "$DISTRO" = "debian" ]; then
    sudo apt install -y 
fi
echo "==> [2/4] Pobieranie dotfiles"

git clone https://github.com/mgrslider/.dotfiles.git ~/.dotfiles

echo "==> [3/4] Instalacja dotfiles"

cd ~/.dotfiles
./install.sh
cd ~

echo "==> [4/4] Poprawki do logowania"

CURRENT_DM=$(basename "$(readlink -f /etc/systemd/system/display-manager.service)" .service 2>/dev/null || true)
if [ -n "$CURRENT_DM" ]; then
    sudo systemctl disable "$CURRENT_DM"
fi

sudo systemctl set-default multi-user.target
echo "exec i3" > "$HOME/.xinitrc"

echo ""
echo "==> Gotowe. Zalecany reboot."
