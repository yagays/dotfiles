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
