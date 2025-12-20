#!/bin/bash

# Define directories
ZSH_CUSTOM="/home/node/.oh-my-zsh/custom"
ZSHRC="/home/node/.zshrc"

echo "Installing Zsh Plugins..."

# 1. Install Zsh Syntax Highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# 2. Install Zsh Autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# 3. Install FZF-Tab 
if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  git clone https://github.com/Aloxaf/fzf-tab $ZSH_CUSTOM/plugins/fzf-tab
fi

# 4. Install Zsh Completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
fi

echo "Injecting User Configuration..."


cat << 'EOF' > $ZSHRC
# ===================================================================
# SECTION 1 : CONFIGURATION DE OH MY ZSH
# ===================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="af-magic"
# evan ; emotty ; eastwood ; humza : nicoulaj
plugins=(
    git
    zsh-completions
    fzf
    fzf-tab
    sudo
    web-search
    command-not-found
    tmux
    zsh-syntax-highlighting
    zsh-autosuggestions
)

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# ===================================================================
# SECTION 2 : VARIABLES D'ENVIRONNEMENT & PATH
# ===================================================================
export EDITOR='code --wait' # Uses VS Code as editor inside container
export VISUAL='code --wait'
export LANG=en_US.UTF-8

# ===================================================================
# SECTION 3 : ALIAS & FONCTIONS
# ===================================================================

# --- Généraux ---
alias ll='ls -la'
alias ls='ls --color=auto'
alias reload='source ~/.zshrc'
# Note: 'bat' is installed as 'batcat' on Debian/Ubuntu
alias cat='batcat --style=plain'
alias preview='batcat --style=numbers --color=always'

# --- Outils de dev ---
alias gs='git status'
alias gp='git pull'
alias dps="docker ps"
alias dstop="docker stop \$(docker ps -q)"
alias drm="docker rm \$(docker ps -aq)"
alias dlogs="docker logs -f"
# Kubectl aliases (Only work if you install kubectl feature, but kept for safe keeping)
alias kctx="kubectl config use-context"
alias kns="kubectl config set-context --current --namespace"
alias klogs="kubectl logs -f"
alias kpods="kubectl get pods"

# --- Fonctions utiles ---
extract () {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.tbz2)      tar xjf "$1"   ;;
      *.tgz)       tar xzf "$1"   ;;
      *.zip)       unzip "$1"     ;;
      *.7z)        7z x "$1"      ;;
      *)           echo "Impossible d'extraire '$1'" ;;
    esac
  else
    echo "'$1' n'est pas un fichier valide"
  fi
}

# ===================================================================
# SECTION 4 : HISTORIQUE
# ===================================================================
# DevContainers persist history in commandhistory, this ensures we map to it
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups

# ===================================================================
# SECTION 5 : CHARGEMENT
# ===================================================================
source "$ZSH/oh-my-zsh.sh"

# ===================================================================
# SECTION 6 : POST-LOAD & ZOXIDE
# ===================================================================

# Keybindings
bindkey '^q' backward-char
bindkey '^s' down-line-or-history
bindkey '^z' up-line-or-history
bindkey '^d' forward-char

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# FZF-TAB styling
# Using batcat for preview
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls -la --color $realpath'

# Autosuggest color
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'
EOF

echo "Zsh setup complete!"