#!/bin/bash

# zsh-setup: Full automatic installation script for Ubuntu/Debian
# Installs dependencies, configures zsh, and sets as default shell

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

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    elif command_exists lsb_release; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    fi
    echo "$OS"
}

# Prompt for installation mode
select_install_mode() {
    echo ""
    echo -e "${BLUE}Select installation mode:${NC}"
    echo "  1) User install (recommended) - Install for current user only"
    echo "  2) Root install - Install system-wide for all users"
    echo ""

    # Check if we're in non-interactive mode
    if [ ! -t 0 ]; then
        print_warning "Non-interactive mode detected, defaulting to user install"
        return 1  # User install
    fi

    read -p "Enter choice [1-2] (default: 1): " choice
    case "$choice" in
        2)
            return 0  # Root install
            ;;
        1|"")
            return 1  # User install
            ;;
        *)
            print_error "Invalid choice. Defaulting to user install."
            return 1
            ;;
    esac
}

# Main installation
main() {
    print_step "Starting full automatic zsh-setup installation"

    OS=$(detect_os)
    print_info "Detected OS: $OS"

    # Select installation mode
    if select_install_mode; then
        INSTALL_MODE="root"
        INSTALL_DIR="/usr/local/share/oh-my-zsh"
        ZSHRC_TEMPLATE="/etc/zsh/zshrc"
        print_info "Installation mode: System-wide (root)"

        # Check if running as root
        if [ "$EUID" -ne 0 ]; then
            print_error "Root installation requires sudo/root privileges"
            print_info "Please run with: curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/auto-install.sh | sudo bash"
            exit 1
        fi
    else
        INSTALL_MODE="user"
        INSTALL_DIR="$HOME"
        ZSHRC_TEMPLATE="$HOME/.zshrc"
        print_info "Installation mode: User-only"
    fi

    # Install dependencies based on OS
    print_step "Installing dependencies"

    case "$OS" in
        ubuntu|debian|pop)
            print_info "Installing zsh, fzf, git, and curl..."
            if ! sudo apt update; then
                print_error "Failed to update package list"
                exit 1
            fi
            if ! sudo apt install -y zsh fzf git curl; then
                print_error "Failed to install dependencies"
                exit 1
            fi
            ;;
        fedora|rhel|centos)
            print_info "Installing zsh, fzf, git, and curl..."
            sudo dnf install -y zsh fzf git curl || sudo yum install -y zsh fzf git curl
            ;;
        arch|manjaro)
            print_info "Installing zsh, fzf, git, and curl..."
            sudo pacman -S --noconfirm zsh fzf git curl
            ;;
        darwin)
            print_info "Installing zsh, fzf, and git via Homebrew..."
            if ! command_exists brew; then
                print_error "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew install zsh fzf git
            ;;
        *)
            print_error "Unsupported OS: $OS"
            echo "Please install zsh, fzf, git, and curl manually, then run install.sh"
            exit 1
            ;;
    esac

    print_success "Dependencies installed successfully"

    # Set installation paths based on mode
    if [ "$INSTALL_MODE" = "root" ]; then
        OMZ_DIR="/usr/local/share/oh-my-zsh"
        ZSH_CUSTOM="$OMZ_DIR/custom"
        TARGET_ZSHRC="/etc/zsh/zshrc.zsh-setup"
        USER_HOME=$(eval echo ~$SUDO_USER)
    else
        OMZ_DIR="$HOME/.oh-my-zsh"
        ZSH_CUSTOM="$OMZ_DIR/custom"
        TARGET_ZSHRC="$HOME/.zshrc"
        USER_HOME="$HOME"
    fi

    # Backup existing .zshrc
    if [ -f "$TARGET_ZSHRC" ] || [ -f "$HOME/.zshrc" ]; then
        print_step "Backing up existing .zshrc"
        BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        if [ -f "$TARGET_ZSHRC" ]; then
            cp "$TARGET_ZSHRC" "$BACKUP_FILE"
        elif [ -f "$HOME/.zshrc" ]; then
            cp "$HOME/.zshrc" "$BACKUP_FILE"
        fi
        print_success "Backup created: $BACKUP_FILE"
    fi

    # Install Oh My Zsh
    print_step "Installing Oh My Zsh"
    if [ ! -d "$OMZ_DIR" ]; then
        if [ "$INSTALL_MODE" = "root" ]; then
            # Manual installation for system-wide
            git clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
            chmod -R 755 "$OMZ_DIR"
        else
            # Standard Oh My Zsh installer for user
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
        print_success "Oh My Zsh installed to: $OMZ_DIR"
    else
        print_info "Oh My Zsh is already installed at: $OMZ_DIR"
    fi

    # Install zsh-autosuggestions
    print_step "Installing zsh-autosuggestions plugin"
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        mkdir -p "$ZSH_CUSTOM/plugins"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        [ "$INSTALL_MODE" = "root" ] && chmod -R 755 "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    else
        print_info "zsh-autosuggestions is already installed"
    fi

    # Install zsh-syntax-highlighting
    print_step "Installing zsh-syntax-highlighting plugin"
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        mkdir -p "$ZSH_CUSTOM/plugins"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        [ "$INSTALL_MODE" = "root" ] && chmod -R 755 "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    else
        print_info "zsh-syntax-highlighting is already installed"
    fi

    # Download and apply .zshrc configuration
    print_step "Configuring .zshrc"
    TEMP_ZSHRC=$(mktemp)
    if curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/zshrc -o "$TEMP_ZSHRC"; then
        if [ "$INSTALL_MODE" = "root" ]; then
            # Modify paths for system-wide installation
            sed -i "s|export ZSH=\$HOME/.oh-my-zsh|export ZSH=$OMZ_DIR|g" "$TEMP_ZSHRC"
            cp "$TEMP_ZSHRC" "$TARGET_ZSHRC"
            chmod 644 "$TARGET_ZSHRC"

            # Create symlink in user's home
            if [ -n "$SUDO_USER" ]; then
                ln -sf "$TARGET_ZSHRC" "$USER_HOME/.zshrc"
                chown -h "$SUDO_USER:$SUDO_USER" "$USER_HOME/.zshrc"
                print_info "Created symlink: $USER_HOME/.zshrc -> $TARGET_ZSHRC"
            fi
        else
            cp "$TEMP_ZSHRC" "$TARGET_ZSHRC"
        fi
        rm -f "$TEMP_ZSHRC"
        print_success ".zshrc configured at: $TARGET_ZSHRC"
    else
        rm -f "$TEMP_ZSHRC"
        print_warning "Failed to download zshrc, using default configuration"
    fi

    # Migrate important environment variables from .bashrc to .zshrc
    print_step "Migrating environment variables from .bashrc to .zshrc"
    BASHRC_FILE="$USER_HOME/.bashrc"
    if [ -f "$BASHRC_FILE" ]; then
        # Create a temporary file to store extracted variables
        TEMP_ENV=$(mktemp)

        # Extract important patterns from .bashrc
        grep -E "^export (NVM_DIR|CLAUDE|ANTHROPIC|PYENV|RBENV|GOPATH|JAVA_HOME|ANDROID)" "$BASHRC_FILE" > "$TEMP_ENV" 2>/dev/null || true
        grep -E "^\[ -s.*nvm\.sh" "$BASHRC_FILE" >> "$TEMP_ENV" 2>/dev/null || true
        grep -E "^source.*(nvm|claude|pyenv|rbenv)" "$BASHRC_FILE" >> "$TEMP_ENV" 2>/dev/null || true
        grep -E "^\. .*(nvm|claude|pyenv|rbenv)" "$BASHRC_FILE" >> "$TEMP_ENV" 2>/dev/null || true
        grep -E "^eval.*\(.*init" "$BASHRC_FILE" >> "$TEMP_ENV" 2>/dev/null || true

        # Also check for PATH modifications
        grep -E "^export PATH=.*:" "$BASHRC_FILE" | grep -v "^#" >> "$TEMP_ENV" 2>/dev/null || true

        if [ -s "$TEMP_ENV" ]; then
            print_info "Found environment variables to migrate:"
            cat "$TEMP_ENV" | while IFS= read -r line; do
                echo "  $line"
            done

            # Append to .zshrc
            echo "" >> "$TARGET_ZSHRC"
            echo "# ============================================" >> "$TARGET_ZSHRC"
            echo "# Migrated from .bashrc" >> "$TARGET_ZSHRC"
            echo "# ============================================" >> "$TARGET_ZSHRC"
            cat "$TEMP_ENV" >> "$TARGET_ZSHRC"
            echo "" >> "$TARGET_ZSHRC"

            print_success "Migrated environment variables to .zshrc"
        else
            print_info "No special environment variables found in .bashrc"
        fi

        rm -f "$TEMP_ENV"
    else
        print_warning ".bashrc not found, skipping migration"
    fi

    # Set zsh as default shell
    print_step "Setting zsh as default shell"

    # Determine target user
    if [ "$INSTALL_MODE" = "root" ] && [ -n "$SUDO_USER" ]; then
        TARGET_USER="$SUDO_USER"
    else
        TARGET_USER="$USER"
    fi

    CURRENT_SHELL=$(getent passwd "$TARGET_USER" | cut -d: -f7)
    ZSH_PATH=$(which zsh)

    if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
        print_info "Current shell: $CURRENT_SHELL"
        print_info "Changing to: $ZSH_PATH"

        # Try to change shell
        if command_exists chsh; then
            if [ "$INSTALL_MODE" = "root" ]; then
                if chsh -s "$ZSH_PATH" "$TARGET_USER" 2>/dev/null; then
                    print_success "Default shell changed to zsh for $TARGET_USER"
                    print_warning "Please log out and log back in for changes to take effect"
                else
                    print_warning "Automatic shell change failed. Trying alternative method..."
                    if usermod -s "$ZSH_PATH" "$TARGET_USER" 2>/dev/null; then
                        print_success "Default shell changed to zsh (via usermod)"
                        print_warning "Please log out and log back in for changes to take effect"
                    else
                        print_error "Failed to change default shell automatically."
                        echo "Please run this command manually:"
                        echo "  sudo chsh -s \$(which zsh) $TARGET_USER"
                    fi
                fi
            else
                if sudo chsh -s "$ZSH_PATH" "$TARGET_USER" 2>/dev/null; then
                    print_success "Default shell changed to zsh"
                    print_warning "Please log out and log back in for changes to take effect"
                else
                    print_warning "Automatic shell change failed. Trying alternative method..."
                    if sudo usermod -s "$ZSH_PATH" "$TARGET_USER" 2>/dev/null; then
                        print_success "Default shell changed to zsh (via usermod)"
                        print_warning "Please log out and log back in for changes to take effect"
                    else
                        print_error "Failed to change default shell automatically."
                        echo "Please run this command manually:"
                        echo "  sudo chsh -s \$(which zsh) \$USER"
                    fi
                fi
            fi
        else
            print_warning "chsh command not found. Using usermod..."
            if [ "$INSTALL_MODE" = "root" ]; then
                if usermod -s "$ZSH_PATH" "$TARGET_USER"; then
                    print_success "Default shell changed to zsh"
                    print_warning "Please log out and log back in for changes to take effect"
                else
                    print_error "Failed to change shell. Please run manually:"
                    echo "  sudo usermod -s \$(which zsh) $TARGET_USER"
                fi
            else
                if sudo usermod -s "$ZSH_PATH" "$TARGET_USER"; then
                    print_success "Default shell changed to zsh"
                    print_warning "Please log out and log back in for changes to take effect"
                else
                    print_error "Failed to change shell. Please run manually:"
                    echo "  sudo usermod -s \$(which zsh) \$USER"
                fi
            fi
        fi
    else
        print_success "zsh is already your default shell"
    fi

    # Add zsh auto-start to .bashrc as fallback
    print_step "Adding zsh fallback to .bashrc"
    if [ -f "$BASHRC_FILE" ]; then
        # Check if zsh auto-start is already in .bashrc
        if ! grep -q "exec zsh" "$BASHRC_FILE" 2>/dev/null; then
            cat >> "$BASHRC_FILE" << 'BASHRC_EOF'

# Auto-start zsh if available (added by zsh-setup)
if [ -x "$(command -v zsh)" ] && [ -z "$ZSH_VERSION" ]; then
    export SHELL=$(which zsh)
    exec zsh
fi
BASHRC_EOF
            print_success "Added zsh auto-start to .bashrc"
            print_info "This ensures zsh starts even if default shell change fails"
        else
            print_info ".bashrc already configured for zsh"
        fi
    else
        print_warning ".bashrc not found, skipping fallback setup"
    fi

    # Final message
    print_step "Installation complete!"
    echo ""
    print_success "zsh-setup completed successfully!"
    echo ""
    print_info "📦 Installation mode: ${INSTALL_MODE}"
    if [ "$INSTALL_MODE" = "root" ]; then
        echo "  • Oh My Zsh location: $OMZ_DIR"
        echo "  • Config file: $TARGET_ZSHRC"
        echo "  • User symlink: $USER_HOME/.zshrc"
    else
        echo "  • Oh My Zsh location: $OMZ_DIR"
        echo "  • Config file: $TARGET_ZSHRC"
    fi
    echo ""
    print_info "✨ Features installed:"
    echo "  • Oh My Zsh framework"
    echo "  • Auto-suggestions (Tab to accept)"
    echo "  • Syntax highlighting"
    echo "  • Fuzzy history search (Ctrl+R)"
    echo "  • Smart completion"
    echo "  • 10,000 command history"
    echo ""
    print_info "🎯 Next steps:"
    echo "  ⚠️  IMPORTANT: Log out and log back in for zsh to become default shell"
    echo "  Or start zsh now with: zsh"
    echo ""
    print_info "⌨️  Key bindings:"
    echo "  • Ctrl+R    : Fuzzy history search"
    echo "  • Tab       : Accept auto-suggestion"
    echo "  • ↑/↓       : Navigate history"
    echo "  • ESC ESC   : Add 'sudo' to command"
    echo ""
    print_success "Enjoy your new zsh setup! 🚀"
}

# Run main function
main "$@"
