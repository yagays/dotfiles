# .zshenv
export PATH=$HOME/local/bin:$PATH
export MANPATH=$HOME/local/share/man:$MANPATH

export EDITOR=emacs

export PERL_CPANM_OPT="--local-lib=~/.cpanm/"
export PERL5LIB="$HOME/.cpanm/lib/perl5:$PERL5LIB"

export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/usr/local/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/usr/local/include:$CPLUS_INCLUDE_PATH

# .zshrc

# History "{{{1
HISTFILE=${HOME}/.zsh_history
SAVEHIST=10000
HISTSIZE=10000
setopt append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_nodups
setopt share_history

# Directory "{{{1
DIRSTACKSIZE=8
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus
setopt pushd_silent
setopt pushd_to_home

# Completion "{{{1
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

# zsh-completions
# git clone git://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
# fpath=(~/.zsh/zsh-completions/src ${fpath})
# autoload -U compinit
# compinit -u

# Prompt "{{{1
autoload -U colors; colors
setopt prompt_subst
unsetopt transient_rprompt

# gitブランチ名をRPROMPTに表示
# http://d.hatena.ne.jp/uasi/20091025/1256458798
autoload -Uz VCS_INFO_get_data_git; VCS_INFO_get_data_git 2> /dev/null

function rprompt-git-current-branch {
        local name st color gitdir action
        if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
                return
        fi
        name=`git branch 2> /dev/null | grep '^\*' | cut -b 3-`
        if [[ -z $name ]]; then
                return
        fi

        gitdir=`git rev-parse --git-dir 2> /dev/null`
        action=`VCS_INFO_git_getaction "$gitdir"` && action="($action)"

        st=`git status 2> /dev/null`
        if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
                color=%F{green}
        elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
                color=%F{yellow}
        elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
                color=%B%F{red}
        else
                 color=%F{red}
         fi
        echo "$color$name$action%f%b "
}
setopt prompt_subst


if [ $SSH_CONNECTION ] || [ $REMOTEHOST ]; then
  PROMPT='%{%(!.$bg[default].%(?.$bg[blue].$bg[red]))%}%n@%m:%(5~,%-2~/.../%2~,%~)%#%{$reset_color%} '
  RPROMPT='%{%(!.$bg[default].%(?.$bg[blue].$bg[red]))%}[`date +%Y/%m/%d` %T]%{$reset_color%}'
else
  PROMPT='%{%(!.$bg[default].%(?.$bg[green].$bg[yellow]))%}%n@%m:%(5~,%-2~/.../%2~,%~)%#%{$reset_color%} '
  RPROMPT='`rprompt-git-current-branch` %{%(!.$bg[default].%(?.$bg[green].$bg[yellow]))%}[`date +%Y/%m/%d` %T]%{$reset_color%}'
fi

# Misc "{{{1
umask 022
limit coredumpsize 0
stty erase '^h'
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

autoload -Uz zmv
alias zmv='noglob zmv -W'

# History search "{{{1
autoload -U  up-line-or-beginning-search
zle      -N  up-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search

autoload -U  down-line-or-beginning-search
zle      -N  down-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search

# Abbreviation "{{{1
typeset -A myAbbrev
myAbbrev=(
"L" "| less"
"G" "| grep"
"H" "| head"
"T" "| tail"
"W" "| wc"
"A" "| awk"
"S" "| sed"
"Y" "yes |"
"...." "../.."
"P" "| pbcopy"
"J" "| jq"
)
function my-expand-abbrev() {
  emulate -L zsh
  setopt extendedglob
  typeset MATCH
  LBUFFER="${LBUFFER%%(#m)[^[:blank:]]#}${myAbbrev[${MATCH}]:-${MATCH}}${KEYS}"
}
zle -N my-expand-abbrev
bindkey " " my-expand-abbrev

# For GNU screen "{{{1
if [ "$TERM" = "screen" ]; then
  chpwd () { echo -n "_`dirs`\\" }
  preexec() {
    emulate -L zsh
    local -a cmd; cmd=(${(z)2})
    case $cmd[1] in
      fg)
      if (( $#cmd == 1 )); then
        cmd=(builtin jobs -l %+)
      else
        cmd=(builtin jobs -l $cmd[2])
      fi
      ;;
      %*)
      cmd=(builtin jobs -l $cmd[1])
      ;;
      cd)
      if (( $#cmd == 2)); then
        cmd[1]=$cmd[2]
      fi
      ;&
      *)
      echo -n "k$cmd[1]:t\\"
      return
      ;;
    esac

    local -A jt; jt=(${(kv)jobtexts})

    $cmd >>(read num rest
    cmd=(${(z)${(e):-¥$jt$num}})
    echo -n "k$cmd[1]:t\\") 2>/dev/null
  }
  chpwd
fi

if [ "$TERM" = "screen" ]; then
  precmd(){
    screen -X title $(basename $(print -P "%~")) >/dev/null
  }
fi

# Aliases "{{{1
setopt aliases
alias l='ls -F --color=auto'
alias ls='ls -F --color=auto'
alias ll='ls -lF --color=auto'
alias la='ls -aF --color=auto'
alias lla='ls -laF --color=auto'
alias x='exit'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'
alias dirs='dirs -v'
alias pd='popd'
alias b='cd ../'
alias s='screen'
alias v='vim'
alias r='rails'
alias e='emacs'
alias sless='less -S'
alias lasth='last | head'
alias grep='grep --color=auto'
alias op='open .'
alias today='date +%Y%m%d'
alias nkf2utf8='nkf -w'
alias jless='jq . -C | less -R'
alias tree='tree -N'

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# python
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    export WORKON_HOME=$HOME/.virtualenvs
    source /usr/local/bin/virtualenvwrapper.sh
fi

# Golang
export GOPATH=~/.go
export PATH=$GOPATH/bin:$PATH
