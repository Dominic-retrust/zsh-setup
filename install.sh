#!/bin/bash

# zsh-setup: User-level zsh installation and configuration script
# No sudo required (except for package installation which will prompt)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "\n${BLUE}==>${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main installation
main() {
    print_step "Starting zsh setup installation"

    # Check if zsh is installed
    if ! command_exists zsh; then
        print_warning "zsh is not installed."
        echo "Please install zsh first:"
        echo "  Ubuntu/Debian: sudo apt install -y zsh"
        echo "  macOS: brew install zsh"
        echo "  Arch: sudo pacman -S zsh"
        exit 1
    fi
    print_success "zsh is already installed"

    # Check if fzf is installed
    if ! command_exists fzf; then
        print_warning "fzf is not installed."
        echo "Please install fzf first:"
        echo "  Ubuntu/Debian: sudo apt install -y fzf"
        echo "  macOS: brew install fzf"
        echo "  Arch: sudo pacman -S fzf"
        exit 1
    fi
    print_success "fzf is already installed"

    # Backup existing .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        print_step "Backing up existing .zshrc"
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Backup created"
    fi

    # Install Oh My Zsh
    print_step "Installing Oh My Zsh"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_info "Oh My Zsh is already installed"
    fi

    # Install zsh-autosuggestions
    print_step "Installing zsh-autosuggestions plugin"
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    else
        print_info "zsh-autosuggestions is already installed"
    fi

    # Install zsh-syntax-highlighting
    print_step "Installing zsh-syntax-highlighting plugin"
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    else
        print_info "zsh-syntax-highlighting is already installed"
    fi

    # Copy .zshrc configuration
    print_step "Configuring .zshrc"
    if [ -f "$(dirname "$0")/zshrc" ]; then
        cp "$(dirname "$0")/zshrc" "$HOME/.zshrc"
        print_success ".zshrc configured"
    else
        print_warning "zshrc template not found, skipping"
    fi

    # Set zsh as default shell (requires sudo)
    print_step "Setting zsh as default shell"
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "To set zsh as your default shell, run:"
        echo "  sudo chsh -s \$(which zsh) \$USER"
        echo ""
        read -p "Do you want to set zsh as default shell now? (requires sudo) [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo chsh -s "$(which zsh)" "$USER"
            print_success "Default shell changed to zsh"
        else
            print_info "You can change it later with: sudo chsh -s \$(which zsh) \$USER"
        fi
    else
        print_success "zsh is already your default shell"
    fi

    # Add zsh auto-start to .bashrc as fallback
    print_step "Adding zsh fallback to .bashrc"
    if [ -f "$HOME/.bashrc" ]; then
        # Check if zsh auto-start is already in .bashrc
        if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
            echo ""
            read -p "Add zsh auto-start to .bashrc? (ensures zsh starts automatically) [Y/n] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                cat >> "$HOME/.bashrc" << 'BASHRC_EOF'

# Auto-start zsh if available (added by zsh-setup)
if [ -x "$(command -v zsh)" ] && [ -z "$ZSH_VERSION" ]; then
    export SHELL=$(which zsh)
    exec zsh
fi
BASHRC_EOF
                print_success "Added zsh auto-start to .bashrc"
                print_info "This ensures zsh starts even if default shell change fails"
            else
                print_info "Skipped .bashrc modification"
            fi
        else
            print_info ".bashrc already configured for zsh"
        fi
    else
        print_warning ".bashrc not found, skipping fallback setup"
    fi

    # Final message
    print_step "Installation complete!"
    echo ""
    print_success "zsh setup completed successfully!"
    echo ""
    echo "To start using zsh:"
    echo "  1. Close and reopen your terminal, or"
    echo "  2. Run: zsh"
    echo ""
    echo "Key features:"
    echo "  • Ctrl+R  : Fuzzy history search"
    echo "  • Tab     : Accept auto-suggestions"
    echo "  • ↑/↓     : Navigate history"
    echo "  • ESC ESC : Add 'sudo' to command"
    echo ""
    print_info "Enjoy your new zsh setup!"
}

# Run main function
main "$@"
