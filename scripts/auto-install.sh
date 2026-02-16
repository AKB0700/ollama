#!/bin/sh
# Universal Ollama Automatic Installer
# This script automatically detects the OS and installs Ollama completely
# Usage: curl -fsSL https://ollama.com/auto-install.sh | sh

set -eu

red="$( (tput bold 2>/dev/null || :; tput setaf 1 2>/dev/null || :) 2>&-)"
green="$( (tput bold 2>/dev/null || :; tput setaf 2 2>/dev/null || :) 2>&-)"
plain="$( (tput sgr0 2>/dev/null || :) 2>&-)"

status() { echo "${green}>>>${plain} $*" >&2; }
error() { echo "${red}ERROR:${plain} $*"; exit 1; }
warning() { echo "${red}WARNING:${plain} $*"; }

# Detect operating system
detect_os() {
    OS="$(uname -s)"
    case "$OS" in
        Linux*)
            OS_TYPE="linux"
            ;;
        Darwin*)
            OS_TYPE="macos"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS_TYPE="windows"
            ;;
        *)
            error "Unsupported operating system: $OS"
            ;;
    esac
}

# Install on Linux
install_linux() {
    status "Detected Linux system"
    status "Running Linux installation script..."
    
    # Download and execute the existing Linux install script
    curl -fsSL https://ollama.com/install.sh | sh
    
    if [ $? -eq 0 ]; then
        status "${green}✓${plain} Ollama successfully installed on Linux!"
        status "You can now run: ollama run gemma3"
    else
        error "Installation failed. Please check the error messages above."
    fi
}

# Install on macOS
install_macos() {
    status "Detected macOS system"
    
    # Check if Ollama is already installed
    if [ -d "/Applications/Ollama.app" ]; then
        warning "Ollama is already installed at /Applications/Ollama.app"
        printf "Do you want to reinstall? (y/N): "
        read -r REPLY
        case "$REPLY" in
            [Yy]|[Yy][Ee][Ss])
                status "Proceeding with reinstallation..."
                ;;
            *)
                status "Installation cancelled."
                exit 0
                ;;
        esac
    fi
    
    TEMP_DIR=$(mktemp -d)
    cleanup() { rm -rf "$TEMP_DIR"; }
    trap cleanup EXIT
    
    status "Downloading Ollama for macOS..."
    if ! curl -fsSL -o "$TEMP_DIR/Ollama.dmg" "https://ollama.com/download/Ollama.dmg"; then
        error "Failed to download Ollama.dmg"
    fi
    
    status "Mounting disk image..."
    if ! hdiutil attach "$TEMP_DIR/Ollama.dmg" -nobrowse -quiet; then
        error "Failed to mount Ollama.dmg"
    fi
    
    status "Installing Ollama to /Applications..."
    if [ -d "/Applications/Ollama.app" ]; then
        sudo rm -rf "/Applications/Ollama.app"
    fi
    
    if ! cp -R "/Volumes/Ollama/Ollama.app" "/Applications/"; then
        hdiutil detach "/Volumes/Ollama" -quiet || true
        error "Failed to copy Ollama.app to /Applications"
    fi
    
    status "Unmounting disk image..."
    hdiutil detach "/Volumes/Ollama" -quiet || true
    
    status "Creating symbolic link for CLI..."
    if [ ! -L "/usr/local/bin/ollama" ]; then
        sudo ln -sf "/Applications/Ollama.app/Contents/Resources/ollama" "/usr/local/bin/ollama"
    fi
    
    status "${green}✓${plain} Ollama successfully installed on macOS!"
    status "Starting Ollama..."
    open /Applications/Ollama.app
    
    status "Waiting for Ollama to start..."
    sleep 5
    
    status "Installation complete! You can now run: ollama run gemma3"
}

# Install on Windows (via WSL or Git Bash)
install_windows() {
    status "Detected Windows system"
    
    # Check if we're in WSL - multiple detection methods for reliability
    IS_WSL=false
    if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
        IS_WSL=true
    elif [ -n "$WSL_DISTRO_NAME" ]; then
        IS_WSL=true
    elif [ -d "/mnt/c" ] && [ -d "/mnt/c/Windows" ]; then
        IS_WSL=true
    fi
    
    if [ "$IS_WSL" = true ]; then
        status "Running in WSL - installing Linux version..."
        install_linux
        return
    fi
    
    error "Direct Windows installation from shell is not supported."
    status "Please use one of these methods:"
    status "1. Download and run: https://ollama.com/download/OllamaSetup.exe"
    status "2. Or use PowerShell: irm https://ollama.com/auto-install.ps1 | iex"
    exit 1
}

# Main installation flow
main() {
    status "Ollama Automatic Installer"
    status "=========================="
    
    detect_os
    
    case "$OS_TYPE" in
        linux)
            install_linux
            ;;
        macos)
            install_macos
            ;;
        windows)
            install_windows
            ;;
        *)
            error "Unsupported OS type: $OS_TYPE"
            ;;
    esac
    
    status ""
    status "${green}Installation Complete!${plain}"
    status "=========================="
    status "Next steps:"
    status "1. Run 'ollama run gemma3' to start chatting"
    status "2. Visit https://ollama.com/library for more models"
    status "3. Check https://docs.ollama.com for documentation"
}

main
