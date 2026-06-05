#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="$HOME/.local/bin:$PATH"

# Prompt: oh-my-posh (0sadiPaper theme)
eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/0sadipaper.omp.json)"

# System info when opening a terminal
fastfetch
