# zsh-setup

Quick and easy zsh installation and configuration script with powerful features.

## Features

- 🚀 **Oh My Zsh** - Powerful zsh framework
- 💡 **Auto-suggestions** - Command suggestions based on history
- 🎨 **Syntax Highlighting** - Real-time command syntax highlighting
- 🔍 **Fuzzy Search** - Powerful history search with fzf (Ctrl+R)
- ⌨️  **Tab Completion** - Accept suggestions with Tab key
- 📝 **Smart History** - 10,000 command history with deduplication
- 🎯 **No sudo required** - User-level installation (except for package dependencies)

## Quick Install

### 🚀 Full Automatic Installation (Recommended for Ubuntu/Debian)

**Everything in one command** - installs dependencies, configures zsh, and sets as default shell:

#### User Installation (Recommended)
Installs zsh configuration for the current user only:
```bash
curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/auto-install.sh | bash
```
**Automatically installs to:** `~/.oh-my-zsh` (current user only)

#### System-wide Installation (Root)
Installs zsh configuration system-wide for all users:
```bash
curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/auto-install.sh | sudo bash
```
**Automatically installs to:** `/usr/local/share/oh-my-zsh` (all users)

**How it works:**
- Running **without sudo**: Automatically selects user installation
- Running **with sudo**: Automatically selects system-wide installation
- Both methods work seamlessly with the `curl | bash` pattern!

**This will:**
- ✅ Install zsh, fzf, git, curl automatically
- ✅ Configure Oh My Zsh with plugins
- ✅ **Analyze and migrate environment from .bashrc** (NVM, PyEnv, RbEnv, custom PATH, aliases)
- ✅ Set zsh as your default shell
- ✅ No manual steps required!

#### Installation Modes Comparison

| Feature | User Install | Root Install |
|---------|-------------|--------------|
| **Command** | `curl ... \| bash` | `curl ... \| sudo bash` |
| **Installation Location** | `~/.oh-my-zsh` | `/usr/local/share/oh-my-zsh` |
| **Config File** | `~/.zshrc` (direct) | `~/.zshrc` (direct) |
| **.bashrc Migration** | ✅ Automatic | ✅ Automatic per user |
| **Available To** | Current user only | All users on the system |
| **Recommended For** | Personal systems, single user | Multi-user servers, shared systems |
| **Auto-detected** | ✅ When not root | ✅ When running as root |

### 📦 Manual Installation (if dependencies are already installed)

```bash
# If you already have zsh and fzf installed
curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/install.sh | bash
```

### 🔧 Clone and Run

```bash
git clone https://github.com/Dominic-retrust/zsh-setup.git
cd zsh-setup

# Full automatic (installs dependencies)
./auto-install.sh

# Or manual (requires zsh and fzf)
./install.sh
```

## Prerequisites

### For `auto-install.sh` (Automatic)
- Ubuntu/Debian/Pop!_OS (will auto-install: zsh, fzf, git, curl)
- Fedora/RHEL/CentOS (will auto-install: zsh, fzf, git, curl)
- Arch/Manjaro (will auto-install: zsh, fzf, git, curl)
- sudo access (for package installation)

### For `install.sh` (Manual)
You need to install these first:

### Ubuntu/Debian
```bash
sudo apt install -y zsh fzf git curl
```

### macOS
```bash
brew install zsh fzf git
```

### Arch Linux
```bash
sudo pacman -S zsh fzf git
```

## What's Included

### Plugins
- **git** - Git aliases and functions
- **zsh-autosuggestions** - Command suggestions
- **zsh-syntax-highlighting** - Syntax highlighting
- **history** - History management
- **sudo** - ESC ESC to add sudo
- **colored-man-pages** - Colorized man pages

### Key Bindings
- **Ctrl + R** - Fuzzy history search
- **Tab** - Accept auto-suggestion
- **Shift + Tab** - Accept auto-suggestion (alternative)
- **Ctrl + Space** - Accept auto-suggestion (alternative)
- **→** (Right Arrow) - Accept auto-suggestion
- **ESC ESC** - Add 'sudo' to current command
- **↑ / ↓** - Navigate history

### History Features
- 10,000 command history
- Automatic deduplication
- Shared between sessions
- Instant append to history file

### Environment Migration
- **Automatic**: Analyzes `.bashrc` and extracts important configurations
- **Supported**:
  - Environment variables: NVM_DIR, PYENV, RBENV, GOPATH, JAVA_HOME, ANDROID_HOME, etc.
  - Tool initialization: NVM, PyEnv, RbEnv, Cargo/Rust
  - PATH modifications
  - Custom aliases and functions
- **Smart**:
  - Only extracts active (uncommented) lines
  - Removes duplicates while preserving order
  - Integrates seamlessly with zsh configuration
- **Safe**:
  - Preserves original `.bashrc` file
  - Creates timestamped backups of existing `.zshrc`
  - Works in both user and root installation modes

### Completion Features
- Case-insensitive completion
- Colorized completion menu
- Complete in the middle of words
- Smart menu navigation

## Usage

After installation:

```bash
# Start zsh (if not default shell)
zsh

# Reload configuration
source ~/.zshrc
# or
zshreload

# Edit configuration
zshconfig
```

## Customization

Your `.zshrc` file is located at `~/.zshrc`.

**Important:** Add your custom configurations in the "User Configuration" section:
```bash
# ============================================
# User Configuration
# ============================================
# Add your custom configurations below

# Your custom aliases, functions, exports here
alias myalias='echo "hello"'
export MY_VAR="value"
```

This ensures your customizations are preserved during reinstallation.

### Change Theme

Edit `~/.zshrc` and change:
```bash
ZSH_THEME="robbyrussell"
```

Popular themes: `agnoster`, `powerlevel10k`, `spaceship`

### Add Plugins

Edit the `plugins` array in `~/.zshrc`:
```bash
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  # Add more plugins here
)
```

## Backup and Reinstallation

### Automatic Backup
The installation script automatically backs up your existing `.zshrc` to:
```
~/.zshrc.backup.YYYYMMDD_HHMMSS
```

### Safe Reinstallation
When you reinstall zsh-setup, the script intelligently:
- ✅ **Preserves user custom configurations** added to "User Configuration" section
- ✅ **Prevents duplicates** from .bashrc migration
- ✅ **Updates to latest template** while keeping your customizations
- ✅ **Creates backup** before making any changes

**Example reinstallation workflow:**
```bash
# First installation
curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/auto-install.sh | bash

# User adds custom aliases to ~/.zshrc
echo 'alias myproject="cd ~/projects/myapp"' >> ~/.zshrc

# Later, reinstall to get updates
curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/auto-install.sh | bash
# ✓ Template updated
# ✓ .bashrc content refreshed
# ✓ Custom aliases preserved!
```

## Troubleshooting

### zsh not found
Install zsh first:
```bash
sudo apt install -y zsh  # Ubuntu/Debian
```

### fzf not found
Install fzf:
```bash
sudo apt install -y fzf  # Ubuntu/Debian
```

### Plugins not working
Reload your configuration:
```bash
source ~/.zshrc
```

### Default shell not changed
Run manually:
```bash
sudo chsh -s $(which zsh) $USER
```
Then log out and log back in.

## Uninstall

To uninstall and restore bash:

```bash
# Remove Oh My Zsh
rm -rf ~/.oh-my-zsh

# Restore backup
mv ~/.zshrc.backup.* ~/.zshrc

# Change default shell back to bash
sudo chsh -s $(which bash) $USER
```

## Security

- All installations are done at user-level in `$HOME`
- No system files are modified (except default shell change which requires sudo)
- Plugins are installed from official verified repositories
- You can review the script before running

## License

MIT License - Feel free to use and modify!

## Contributing

Pull requests are welcome! For major changes, please open an issue first.

## Credits

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [fzf](https://github.com/junegunn/fzf)
