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

```bash
# One-line installation
curl -fsSL https://raw.githubusercontent.com/Dominic-retrust/zsh-setup/main/install.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/Dominic-retrust/zsh-setup.git
cd zsh-setup
chmod +x install.sh
./install.sh
```

## Prerequisites

The script will check for these dependencies and prompt you to install them:

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

Your `.zshrc` file is located at `~/.zshrc`. You can add your custom configurations at the bottom of the file.

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

## Backup

The installation script automatically backs up your existing `.zshrc` to:
```
~/.zshrc.backup.YYYYMMDD_HHMMSS
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
