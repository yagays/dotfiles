# Path
export PATH=$HOME/local/bin:$PATH
export MANPATH=$HOME/local/share/man:$MANPATH
export EDITOR=emacs

export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/usr/local/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/usr/local/include:$CPLUS_INCLUDE_PATH

# for ls in macOS
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH

# Directory
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus
setopt pushd_silent
setopt pushd_to_home

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

# History
export LANG=ja_JP.UTF-8
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

# Prompt
autoload -U colors; colors
setopt prompt_subst
unsetopt transient_rprompt

autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }

if [ $SSH_CONNECTION ] || [ $REMOTEHOST ]; then
  PROMPT='%{%(!.$bg[default].%(?.$bg[blue].$bg[red]))%}%n@%m:%(5~,%-2~/.../%2~,%~)%#%{$reset_color%} '
  RPROMPT='%{%(!.$bg[default].%(?.$bg[blue].$bg[red]))%}[`date +%Y/%m/%d` %T]%{$reset_color%}'
else
  PROMPT='%{%(!.$bg[default].%(?.$bg[green].$bg[yellow]))%}%n@%m:%(5~,%-2~/.../%2~,%~)%#%{$reset_color%} '
  RPROMPT='${vcs_info_msg_0_} %{%(!.$bg[default].%(?.$bg[green].$bg[yellow]))%}[`date +%Y/%m/%d` %T]%{$reset_color%}'
fi

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
alias e='emacs'
alias sless='less -S'
alias lasth='last | head'
alias grep='grep --color=auto'
alias op='open .'
alias ta='tmux attach'
alias tn='tmux new'
alias today='date +%Y%m%d'
alias nkf2utf8='nkf -w'
alias jless='jq . -C | less -R'
alias tree='tree -N'
alias i='ipython'
alias c='code .'
alias hb='hub browse'
alias p='poetry'
alias pr='poetry run'
alias pri='poetry run ipython'
alias prodigy="python -m prodigy"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
export VIRTUAL_ENV_DISABLE_PROMPT=1
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

# poetry
export PATH=$PATH:~/.local/bin/

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'
zinit light zsh-users/zsh-autosuggestions

zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zdharma-continuum/history-search-multi-word
zinit light mollifier/cd-gitroot

zinit light mollifier/anyframe
bindkey '^t' anyframe-widget-cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 1000
zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"

### End of Zinit's installer chunk

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yag_ays/dev/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yag_ays/dev/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/yag_ays/dev/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yag_ays/dev/google-cloud-sdk/completion.zsh.inc'; fi

export PATH=$PATH:~/.nodebrew/current/bin
export NODE_PATH=~/.nodebrew/current/lib/node_modules

# export JAVA_HOME=`/usr/libexec/java_home -v 14`


FZF_GH_PR_EXTRA_ARG=${FZF_GH_PR_EXTRA_ARG:-''}
FZF_GH_PR_BINDKEY=${FZF_GH_PR_BINDKEY:-'^g^p'}

function fzf-gh-pr-selection() {
  local out pr key fzf_command command

  pr_list_command='gh pr list'
  fzf_command='fzf --query "$LBUFFER" --prompt="Pull Request> " --preview="gh pr view {1}" --expect=ctrl-o'
  command="$pr_list_command | $fzf_command"

  IFS=$'\n' out=$(eval $command)
  key=$(echo "$out" | head -1)
  pr=$(echo "$out" | head -2 | tail -1 | awk '{ print $1 }')

  if [[ $pr != "" ]]; then
    if [[ $key == "ctrl-o" ]]; then
      eval "gh pr view --web $pr"
    else
      BUFFER="gh pr checkout $pr"
      CURSOR=$#BUFFER
    fi
  fi
  zle reset-prompt
}
zle -N fzf-gh-pr-selection
bindkey $FZF_GH_PR_BINDKEY fzf-gh-pr-selection
export PATH="/usr/local/opt/ruby/bin:$PATH"

# GCPのプロジェクト切り替え
# https://qiita.com/sonots/items/906798c408132e26b41c
function gcloud-activate() {
  name="$1"
  project="$2"
  echo "gcloud config configurations activate \"${name}\""
  gcloud config configurations activate "${name}"
}
function gx-complete() {
  _values $(gcloud config configurations list | awk '{print $1}')
}
function gx() {
  name="$1"
  if [ -z "$name" ]; then
    line=$(gcloud config configurations list | fzf --header-lines=1)
    name=$(echo "${line}" | awk '{print $1}')
  else
    line=$(gcloud config configurations list | grep "$name")
  fi
  project=$(echo "${line}" | awk '{print $4}')
  gcloud-activate "${name}" "${project}"
}
compdef gx-complete gx

# direnv
eval "$(direnv hook zsh)"


# Rust
export PATH=$PATH:~/.cargo/bin

# fbr - checkout git branch
function fzf-git-checkout() {
  local branches branch
  branches=$(git branch -vv --sort=-committerdate) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
  zle reset-prompt
}
zle -N fzf-git-checkout
bindkey "^g^o" fzf-git-checkout

function fzf-gh-browse() {
  gh browse
}
zle -N fzf-gh-browse
bindkey "^g^w" fzf-gh-browse

function ghq-fzf() {
  local src=$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^]' ghq-fzf
