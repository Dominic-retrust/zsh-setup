# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  history
  sudo
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# ============================================
# History Configuration
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS    # 중복된 명령 제거
setopt HIST_FIND_NO_DUPS       # 검색 시 중복 표시 안함
setopt HIST_REDUCE_BLANKS      # 불필요한 공백 제거
setopt SHARE_HISTORY           # 세션 간 히스토리 공유
setopt APPEND_HISTORY          # 히스토리 덮어쓰기 대신 추가
setopt INC_APPEND_HISTORY      # 즉시 히스토리에 추가

# ============================================
# fzf Configuration
# ============================================
# fzf 키 바인딩 및 자동완성
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
    source /usr/share/doc/fzf/examples/completion.zsh
fi

# macOS fzf path
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# fzf 설정
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# ============================================
# Auto-suggestions Configuration
# ============================================
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# Tab으로 자동 제안 수락하기
bindkey '^I' autosuggest-accept  # Ctrl+I (Tab)는 자동제안 수락
bindkey '^[[Z' autosuggest-accept  # Shift+Tab으로도 수락 가능
bindkey '^ ' autosuggest-accept    # Ctrl+Space로 수락

# ============================================
# Advanced Completion Settings
# ============================================
setopt MENU_COMPLETE        # Tab 한 번에 첫 번째 완성 선택
setopt AUTO_MENU            # 두 번째 Tab에 메뉴 표시
setopt COMPLETE_IN_WORD     # 단어 중간에서도 완성 가능
setopt ALWAYS_TO_END        # 완성 후 커서를 끝으로 이동

# 대소문자 구분 없이 자동완성
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# 색상이 있는 자동완성 메뉴
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ============================================
# Aliases
# ============================================
alias history='history 1'  # 전체 히스토리 표시
alias h='history | grep'   # 히스토리 검색
alias zshconfig="$EDITOR ~/.zshrc"
alias zshreload="source ~/.zshrc"

# ============================================
# User Configuration
# ============================================
# Add your custom configurations below
