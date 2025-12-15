# Misc
umask 022
limit coredumpsize 0
# stty erase '^h'
stty kill '^g'
stty stop 'undef'

bindkey -e

setopt bad_pattern
unsetopt beep
setopt c_bases
setopt check_jobs
unsetopt clobber
unsetopt flow_control
setopt ignore_eof
setopt long_list_jobs
setopt print_eightbit

autoload -U tetris; zle -N tetris
