# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '


. "$HOME/.cargo/env"

# Created by `pipx` on 2025-09-21 19:44:39
export PATH="$PATH:/home/codebarre/.local/bin"
export PATH="$PATH:/home/codebarre/.platformio/penv/bin"
export PATH="$PATH:/home/codebarre/.cargo/bin"

plugins=(
  git
  zsh-autosuggestions
  fast-syntax-highlighting
  docker
  docker-compose
  gapline
)
source $ZSH/oh-my-zsh.sh

eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"
alias ff='fastfetch'
alias vim=nvim
alias lg='lazygit'
alias spotify=spotify_player
