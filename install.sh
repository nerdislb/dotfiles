#!/bin/bash

# Dotfiles Installation Script

echo "Starting installation..."

# 1. Update System
echo "Updating system..."
sudo pacman -Syu --noconfirm

# 2. Install Git (if not present)
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    sudo pacman -S git --noconfirm
fi

# 3. Install Paru (AUR Helper) if not present
if ! command -v paru &> /dev/null; then
    echo "Installing paru..."
    sudo pacman -S --needed base-devel --noconfirm
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
fi

# 4. Install Repo Packages
if [ -f "pkglist_repo.txt" ]; then
    echo "Installing repository packages..."
    sudo pacman -S --needed --noconfirm - < pkglist_repo.txt
fi

# 5. Install AUR Packages
if [ -f "pkglist_aur.txt" ]; then
    echo "Installing AUR packages..."
    paru -S --needed --noconfirm - < pkglist_aur.txt
fi

# 6. Symlink Configurations
echo "Linking configurations..."

CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$(pwd)/config"
SCRIPTS_DIR="$(pwd)/scripts"
BIN_DIR="$HOME/.local/bin"

# Helper function to link directories
link_config() {
    local app_name=$1
    local source_path="$DOTFILES_DIR/$app_name"
    local target_path="$CONFIG_DIR/$app_name"

    if [ -d "$source_path" ]; then
        # Create parent dir if it doesn't exist
        mkdir -p "$CONFIG_DIR"

        if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
            echo "Backing up existing $app_name config..."
            mv "$target_path" "${target_path}.bak.$(date +%s)"
        elif [ -L "$target_path" ]; then
            echo "Updating link for $app_name..."
            rm "$target_path"
        fi
        
        echo "Linking $app_name..."
        ln -sf "$source_path" "$target_path"
    else
        echo "Warning: Config for $app_name not found in dotfiles."
    fi
}

# Helper function to link scripts
link_script() {
    local script_name=$1
    local source_path="$SCRIPTS_DIR/$script_name"
    local target_path="$BIN_DIR/$script_name"

    if [ -f "$source_path" ]; then
        mkdir -p "$BIN_DIR"
        chmod +x "$source_path"
        echo "Linking script $script_name..."
        ln -sf "$source_path" "$target_path"
    else
        echo "Warning: Script $script_name not found in dotfiles."
    fi
}

# Link applications
link_config "waybar"
link_config "btop"
link_config "kitty"
link_config "fish"
link_config "niri"
link_config "wlogout"
link_config "swaync"
link_config "fuzzel"
link_config "swayosd"
link_config "themes"
link_config "hypr"
link_config "alacritty"
link_config "zellij"
link_config "fastfetch"

# Link scripts
link_script "volume-control"
link_script "theme-selector"

# 7. Post-Install Setup
echo "Performing post-install setup..."

# Enable Greeter (Greetd) if installed
if systemctl list-unit-files | grep -q greetd.service; then
    echo "Enabling greetd service..."
    sudo systemctl enable greetd.service
    # Disable GDM if present to avoid conflicts (forcefully)
    if systemctl is-enabled gdm.service &>/dev/null; then
        sudo systemctl disable gdm.service
    fi
fi

# Enable User Services
echo "Enabling user services..."
systemctl --user enable --now swaync.service
systemctl --user enable --now swayosd-libinput.backend.service

# Setup Themes
echo "Setting up TokyoNight Theme permissions..."
chmod +x "$CONFIG_DIR/themes/TokyoNight/apply.sh"

echo "Installation complete! Please restart your system or log out to see all changes."