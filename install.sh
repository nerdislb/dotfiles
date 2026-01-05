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

# Helper function to link directories
link_config() {
    local app_name=$1
    local source_path="$DOTFILES_DIR/$app_name"
    local target_path="$CONFIG_DIR/$app_name"

    if [ -d "$source_path" ]; then
        if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
            echo "Backing up existing $app_name config..."
            mv "$target_path" "${target_path}.bak"
        fi
        
        # Create parent dir if it doesn't exist (unlikely for .config but good practice)
        mkdir -p "$CONFIG_DIR"

        echo "Linking $app_name..."
        ln -sf "$source_path" "$target_path"
    else
        echo "Warning: Config for $app_name not found in dotfiles."
    fi
}

# Link specific applications
link_config "waybar"
link_config "btop"
link_config "kitty"
link_config "fish"
link_config "niri"
link_config "wlogout"

echo "Installation complete! Please restart your shell or session."
