# Abbreviation
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
