#!/bin/bash
# Install zsh and fzf on Linux if not already installed

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
