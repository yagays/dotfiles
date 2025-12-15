# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_nodups
setopt share_history

autoload -U  up-line-or-beginning-search
zle      -N  up-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search

autoload -U  down-line-or-beginning-search
zle      -N  down-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
