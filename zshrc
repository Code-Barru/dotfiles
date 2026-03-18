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

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  docker
  docker-compose
)
source $ZSH/oh-my-zsh.sh

eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"
alias ff='fastfetch'
alias vim=nvim
alias para='cd ~/notes && nvim ~/notes/index.norg'
