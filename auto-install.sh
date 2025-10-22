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
    # If running as root, automatically select root install
    if [ "$EUID" -eq 0 ]; then
        print_info "Running as root - selecting system-wide installation"
        return 0  # Root install
    fi

    # For non-root users, check if interactive
    if [ ! -t 0 ]; then
        print_warning "Non-interactive mode detected, defaulting to user install"
        return 1  # User install
    fi

    # Interactive mode for non-root users
    echo ""
    echo -e "${BLUE}Select installation mode:${NC}"
    echo "  1) User install (recommended) - Install for current user only"
    echo "  2) Root install - Install system-wide for all users (requires sudo)"
    echo ""

    read -p "Enter choice [1-2] (default: 1): " choice </dev/tty
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

    # Determine if we need sudo for package management
    if [ "$EUID" -eq 0 ]; then
        SUDO_CMD=""
    else
        SUDO_CMD="sudo"
    fi

    case "$OS" in
        ubuntu|debian|pop)
            print_info "Installing zsh, fzf, git, and curl..."
            if ! $SUDO_CMD apt update; then
                print_error "Failed to update package list"
                exit 1
            fi
            if ! $SUDO_CMD apt install -y zsh fzf git curl; then
                print_error "Failed to install dependencies"
                exit 1
            fi
            ;;
        fedora|rhel|centos)
            print_info "Installing zsh, fzf, git, and curl..."
            $SUDO_CMD dnf install -y zsh fzf git curl || $SUDO_CMD yum install -y zsh fzf git curl
            ;;
        arch|manjaro)
            print_info "Installing zsh, fzf, git, and curl..."
            $SUDO_CMD pacman -S --noconfirm zsh fzf git curl
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
        USER_HOME=$(eval echo ~$SUDO_USER)
        TARGET_USER="$SUDO_USER"
    else
        OMZ_DIR="$HOME/.oh-my-zsh"
        ZSH_CUSTOM="$OMZ_DIR/custom"
        USER_HOME="$HOME"
        TARGET_USER="$USER"
    fi

    TARGET_ZSHRC="$USER_HOME/.zshrc"

    # Backup existing .zshrc
    if [ -f "$TARGET_ZSHRC" ]; then
        print_step "Backing up existing .zshrc"
        BACKUP_FILE="$USER_HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$TARGET_ZSHRC" "$BACKUP_FILE"
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

    # Extract user custom configurations from existing .zshrc (if exists)
    print_step "Preserving user custom configurations"
    USER_CUSTOM=$(mktemp)

    if [ -f "$TARGET_ZSHRC" ]; then
        # Extract content between "# User Configuration" and "# Migrated from .bashrc"
        awk '
        BEGIN { in_user_section=0; in_custom_section=0 }
        /^# ============================================$/ {
            getline
            # Check if this is the User Configuration section
            if ($0 ~ /^# User Configuration$/) {
                in_user_section=1
                getline  # Skip the next separator
                if ($0 ~ /^# ============================================$/) {
                    getline  # Skip "Add your custom..." line
                }
                next
            }
            # Check if this is Migrated section or User Custom Configuration
            if ($0 ~ /^# Migrated from .bashrc$/ || $0 ~ /^# User Custom Configuration$/) {
                in_user_section=0
                in_custom_section=0
            }
        }
        in_user_section {
            if ($0 !~ /^# Add your custom configurations below$/) {
                print
            }
        }
        ' "$TARGET_ZSHRC" > "$USER_CUSTOM" 2>/dev/null || true

        # Remove leading/trailing empty lines
        if [ -f "$USER_CUSTOM" ]; then
            # Remove leading empty lines
            sed -i '/./,$!d' "$USER_CUSTOM" 2>/dev/null || true
            # Remove trailing empty lines
            sed -i -e :a -e '/^\s*$/{ $d; N; ba' -e '}' "$USER_CUSTOM" 2>/dev/null || true
        fi

        if [ -s "$USER_CUSTOM" ]; then
            print_success "Preserved $(wc -l < "$USER_CUSTOM") lines of user custom configurations"
        else
            print_info "No user custom configurations found in existing .zshrc"
        fi
    else
        print_info "No existing .zshrc found, skipping custom configuration preservation"
    fi

    # Extract and analyze .bashrc content
    print_step "Analyzing .bashrc configuration"
    BASHRC_FILE="$USER_HOME/.bashrc"
    BASHRC_CONTENT=$(mktemp)

    if [ -f "$BASHRC_FILE" ]; then
        # Extract important patterns from .bashrc
        print_info "Extracting environment variables from .bashrc..."

        # Export statements for environment variables
        grep -E "^export (NVM_DIR|CLAUDE|ANTHROPIC|PYENV|RBENV|GOPATH|JAVA_HOME|ANDROID|NODE|PYTHON|RUBY|GO|RUST|CARGO)" "$BASHRC_FILE" >> "$BASHRC_CONTENT" 2>/dev/null || true

        # NVM configuration
        grep -E "^\[.*-s.*nvm\.sh.*\]" "$BASHRC_FILE" >> "$BASHRC_CONTENT" 2>/dev/null || true
        grep -E "^source.*nvm\.sh" "$BASHRC_FILE" >> "$BASHRC_CONTENT" 2>/dev/null || true
        grep -E "^\. .*nvm\.sh" "$BASHRC_FILE" >> "$BASHRC_CONTENT" 2>/dev/null || true

        # Other tool configurations (pyenv, rbenv, etc.)
        grep -E "^source.*(pyenv|rbenv|cargo|rustup)" "$BASHRC_FILE" >> "$BASHRC_CONTENT" 2>/dev/null || true
        grep -E "^\. .*(pyenv|rbenv|cargo|rustup)" "$BASHRC_FILE" >> "$BASHRC_CONTENT" 2>/dev/null || true

        # Eval statements for tool initialization
        grep -E "^eval.*\(.*init" "$BASHRC_FILE" >> "$BASHRC_CONTENT" 2>/dev/null || true

        # PATH modifications (excluding comments)
        grep -E "^export PATH=" "$BASHRC_FILE" | grep -v "^#" >> "$BASHRC_CONTENT" 2>/dev/null || true
        grep -E "^PATH=" "$BASHRC_FILE" | grep -v "^#" >> "$BASHRC_CONTENT" 2>/dev/null || true

        # Custom aliases and functions
        grep -E "^alias " "$BASHRC_FILE" >> "$BASHRC_CONTENT" 2>/dev/null || true

        # Remove duplicates while preserving order
        awk '!seen[$0]++' "$BASHRC_CONTENT" > "$BASHRC_CONTENT.tmp"
        mv "$BASHRC_CONTENT.tmp" "$BASHRC_CONTENT"

        if [ -s "$BASHRC_CONTENT" ]; then
            print_success "Found $(wc -l < "$BASHRC_CONTENT") lines to migrate from .bashrc"
        else
            print_info "No special environment variables found in .bashrc"
        fi
    else
        print_warning ".bashrc not found, will use default configuration only"
    fi

    # Download and build .zshrc configuration
    print_step "Creating .zshrc configuration"
    TEMP_ZSHRC=$(mktemp)

    if curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/zshrc -o "$TEMP_ZSHRC"; then
        # Modify paths based on installation mode
        if [ "$INSTALL_MODE" = "root" ]; then
            # Replace the ZSH path for system-wide installation
            sed -i "s|^export ZSH=\"\$HOME/.oh-my-zsh\"|export ZSH=\"$OMZ_DIR\"|g" "$TEMP_ZSHRC"
        fi

        # Append .bashrc content if available
        if [ -s "$BASHRC_CONTENT" ]; then
            echo "" >> "$TEMP_ZSHRC"
            echo "# ============================================" >> "$TEMP_ZSHRC"
            echo "# Migrated from .bashrc" >> "$TEMP_ZSHRC"
            echo "# ============================================" >> "$TEMP_ZSHRC"
            cat "$BASHRC_CONTENT" >> "$TEMP_ZSHRC"
            echo "" >> "$TEMP_ZSHRC"
        fi

        # Append user custom configurations if available
        if [ -s "$USER_CUSTOM" ]; then
            echo "" >> "$TEMP_ZSHRC"
            echo "# ============================================" >> "$TEMP_ZSHRC"
            echo "# User Custom Configuration" >> "$TEMP_ZSHRC"
            echo "# (Preserved from previous installation)" >> "$TEMP_ZSHRC"
            echo "# ============================================" >> "$TEMP_ZSHRC"
            cat "$USER_CUSTOM" >> "$TEMP_ZSHRC"
            echo "" >> "$TEMP_ZSHRC"
            print_info "User custom configurations restored"
        fi

        # Write final .zshrc
        cp "$TEMP_ZSHRC" "$TARGET_ZSHRC"

        # Set proper ownership for root mode
        if [ "$INSTALL_MODE" = "root" ]; then
            chown "$SUDO_USER:$SUDO_USER" "$TARGET_ZSHRC"
            chmod 644 "$TARGET_ZSHRC"
        fi

        print_success ".zshrc configured at: $TARGET_ZSHRC"
    else
        print_error "Failed to download zshrc template"
        exit 1
    fi

    # Clean up temporary files
    rm -f "$TEMP_ZSHRC" "$BASHRC_CONTENT" "$USER_CUSTOM"

    # Set zsh as default shell
    print_step "Setting zsh as default shell"

    CURRENT_SHELL=$(getent passwd "$TARGET_USER" | cut -d: -f7)
    ZSH_PATH=$(which zsh)

    if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
        print_info "Current shell: $CURRENT_SHELL"
        print_info "Changing to: $ZSH_PATH"

        # Determine sudo command
        if [ "$EUID" -eq 0 ]; then
            CHSH_SUDO=""
        else
            CHSH_SUDO="sudo"
        fi

        # Try to change shell
        if command_exists chsh; then
            if $CHSH_SUDO chsh -s "$ZSH_PATH" "$TARGET_USER" 2>/dev/null; then
                print_success "Default shell changed to zsh for $TARGET_USER"
                print_warning "Please log out and log back in for changes to take effect"
            else
                print_warning "Automatic shell change failed. Trying alternative method..."
                if $CHSH_SUDO usermod -s "$ZSH_PATH" "$TARGET_USER" 2>/dev/null; then
                    print_success "Default shell changed to zsh (via usermod)"
                    print_warning "Please log out and log back in for changes to take effect"
                else
                    print_error "Failed to change default shell automatically."
                    echo "Please run this command manually:"
                    if [ "$EUID" -eq 0 ]; then
                        echo "  chsh -s \$(which zsh) $TARGET_USER"
                    else
                        echo "  sudo chsh -s \$(which zsh) $TARGET_USER"
                    fi
                fi
            fi
        else
            print_warning "chsh command not found. Using usermod..."
            if $CHSH_SUDO usermod -s "$ZSH_PATH" "$TARGET_USER"; then
                print_success "Default shell changed to zsh"
                print_warning "Please log out and log back in for changes to take effect"
            else
                print_error "Failed to change shell. Please run manually:"
                if [ "$EUID" -eq 0 ]; then
                    echo "  usermod -s \$(which zsh) $TARGET_USER"
                else
                    echo "  sudo usermod -s \$(which zsh) $TARGET_USER"
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
    echo "  • Oh My Zsh location: $OMZ_DIR"
    echo "  • Config file: $TARGET_ZSHRC"
    if [ "$INSTALL_MODE" = "root" ]; then
        echo "  • User: $TARGET_USER"
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
