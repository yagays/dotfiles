# Completion
autoload -U compinit
compinit
LISTMAX=0
setopt complete_aliases
setopt complete_in_word
setopt extendedglob
unsetopt list_ambiguous
setopt list_packed
setopt list_types
setopt mark_dirs
setopt numeric_glob_sort
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:warnings' format 'No matches'
export WORDCHARS='*?_.[]~-=&;!#$%^(){}<>'

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# gh completions
eval "$(gh completion -s zsh)"
