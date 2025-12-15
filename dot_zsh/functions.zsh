# Functions
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
    zle reset-prompt
}
zle -N fzf-gh-browse
bindkey "^g^w" fzf-gh-browse

function fzf-gh-open-pr() {
    gh pr view --web
    zle reset-prompt
}
zle -N fzf-gh-open-pr
bindkey "^g^r" fzf-gh-open-pr

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

user_name=$(git config user.name)
fmt="\
%(if:equals=$user_name)%(authorname)%(then)%(color:default)%(else)%(color:brightred)%(end)%(refname:short)|\
%(committerdate:relative)|\
%(subject)"
function select-git-branch-friendly() {
  selected_branch=$(
    git branch --sort=-committerdate --format=$fmt --color=always \
    | column -ts'|' \
    | fzf --ansi --exact --preview='git log --oneline --graph --decorate --color=always -50 {+1}' \
    | awk '{print $1}' \
  )
  BUFFER="${LBUFFER}${selected_branch}${RBUFFER}"
  CURSOR=$#LBUFFER+$#selected_branch
  zle redisplay
}
zle -N select-git-branch-friendly
bindkey '^g^b' select-git-branch-friendly
