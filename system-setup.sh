#!/bin/bash
set -e

MARKER="/mnt/.system_setup"
if [ -f "$MARKER" ]; then
    echo "Skrypt już został wykonany, jeżeli chcesz go wykonać jeszcze raz usuń $MARKER"
    exit 0
fi
sudo touch "$MARKER"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
else
    echo "Nie można wykryć dystrybucji"
    exit 1
fi

echo "==> [1/4] Instalacja pakietów"


if [ "$DISTRO" = "fedora" ]; then
    # --- COPR ---
    sudo dnf copr enable -y scottames/ghostty 
    sudo dnf copr enable -y atim/starship
    sudo dnf copr enable -y zeno/scrcpy

    PACKAGES=(
        i3 i3blocks git vim neovim ghostty 
        unzip curl gnupg rsync htop
        pv gnupg2 tar fzf stow
        rofi feh redshift maim xclip
        xdotool ddcutil lm_sensors smartmontools
        openvpn  firefox thunderbird
        libreoffice keepassxc nautilus
        rclone pipewire pipewire-pulse
        pipewire-alsa wireplumber pavucontrol
        steam xorg-x11-xinit 
        bash-completion scrcpy starship 
    )

    sudo dnf install -y "${PACKAGES[@]}"
fi
if [ "$DISTRO" = "debian" ]; then
    sudo apt update
    sudo apt install -y \
        alacritty
        i3blocks git vim neovim stow fzf \
        unzip curl gnupg rsync htop \
        rofi feh redshift maim xclip \
        xdotool ddcutil lm-sensors smartmontools network-manager \
        network-manager-gnome network-manager-openvpn openvpn \
        blueman bluez firefox-esr thunderbird \
        libreoffice keepassxc nautilus \
        rclone pipewire pipewire-pulse \
        pipewire-alsa wireplumber pavucontrol \
        bash-completion xinit scrcpy

    # --- Włącz contrib + non-free + i386 (dla nvidia i steam) ---
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y contrib non-free non-free-firmware
    sudo dpkg --add-architecture i386
    sudo apt update

    # --- Sterownik nvidia ---
    sudo apt install -y nvidia-driver nvidia-settings

    # --- Steam ---
    sudo apt install -y steam-installer

    # --- starship (brak w apt) ---
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
fi
echo "==> [2/4] Pobieranie dotfiles"

rm -rdf ~/.dotfiles
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
