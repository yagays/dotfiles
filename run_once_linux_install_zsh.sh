#!/bin/bash
# Install zsh and fzf on Linux if not already installed

# Exit if not Linux
if [[ "$(uname)" != "Linux" ]]; then
    exit 0
fi

PACKAGES=""

if ! command -v zsh &> /dev/null; then
    PACKAGES="$PACKAGES zsh"
fi

if ! command -v fzf &> /dev/null; then
    PACKAGES="$PACKAGES fzf"
fi

if [ -n "$PACKAGES" ]; then
    echo "Installing:$PACKAGES"
    sudo apt update && sudo apt install -y $PACKAGES
    echo "Installation completed."
else
    echo "zsh and fzf are already installed."
fi

# Install uv (Python package manager)
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "uv installed successfully."
else
    echo "uv is already installed."
fi

# Install gh (GitHub CLI)
if ! command -v gh &> /dev/null; then
    (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
    echo "gh installed successfully."
    echo "Running gh auth login..."
    gh auth login
else
    echo "gh is already installed."
fi

# Install Claude Code CLI
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code CLI..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://claude.ai/install.sh | bash -s -- --yes --prefix "$HOME/.local"
    echo "Claude Code CLI installed successfully."
else
    echo "Claude Code CLI is already installed."
fi
