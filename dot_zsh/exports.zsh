# Homebrew (must be first to set up base paths)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Path
typeset -U path
path=(
  $HOME/.local/bin
  /usr/local/opt/coreutils/libexec/gnubin
  $HOME/.go/bin
  $HOME/.cargo/bin
  $HOME/.bun/bin
  $HOME/.antigravity/antigravity/bin
  $path
)

# Man Path
typeset -U manpath
manpath=(
  $HOME/.local/share/man
  $manpath
)

# Library Path
export LIBRARY_PATH="/usr/local/lib:/opt/homebrew/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# Include Path
export C_INCLUDE_PATH="/usr/local/include:$C_INCLUDE_PATH"
export CPLUS_INCLUDE_PATH="/usr/local/include:$CPLUS_INCLUDE_PATH"

# LLVM
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib:$LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include:$CPPFLAGS"

# Go
export GOPATH="$HOME/.go"

# Bun
export BUN_INSTALL="$HOME/.bun"

# Editor
export EDITOR=emacs

# Locale
export LANG=ja_JP.UTF-8
