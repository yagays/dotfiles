#!/bin/bash
# Install packages on Linux

# Exit if not Linux
if [[ "$(uname)" != "Linux" ]]; then
    exit 0
fi

# ============================================================
# APT packages
# ============================================================
PACKAGES=""

if ! command -v zsh &> /dev/null; then
    PACKAGES="$PACKAGES zsh"
fi

if ! command -v fzf &> /dev/null; then
    PACKAGES="$PACKAGES fzf"
fi

if ! command -v tig &> /dev/null; then
    PACKAGES="$PACKAGES tig"
fi

if ! command -v tree &> /dev/null; then
    PACKAGES="$PACKAGES tree"
fi

if ! command -v unzip &> /dev/null; then
    PACKAGES="$PACKAGES unzip"
fi

if [ -n "$PACKAGES" ]; then
    echo "Installing:$PACKAGES"
    sudo apt update && sudo apt install -y $PACKAGES
    echo "Installation completed."
else
    echo "APT packages are already installed."
fi

# ============================================================
# External packages (installed via official scripts/repos)
# ============================================================

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

# Install 1Password CLI
if ! command -v op &> /dev/null; then
    echo "Installing 1Password CLI..."
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
        sudo tee /etc/apt/sources.list.d/1password.list && \
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
        sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
        sudo apt update && sudo apt install -y 1password-cli
    echo "1Password CLI installed successfully."
else
    echo "1Password CLI is already installed."
fi

# Install Tailscale
if ! command -v tailscale &> /dev/null; then
    echo "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
    echo "Tailscale installed successfully."
else
    echo "Tailscale is already installed."
fi

# Install Volta (Node.js version manager)
if ! command -v volta &> /dev/null; then
    echo "Installing Volta..."
    curl https://get.volta.sh | bash
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    echo "Volta installed successfully."
else
    echo "Volta is already installed."
fi

# Install Node.js via Volta
if command -v volta &> /dev/null; then
    if ! volta list node 2>/dev/null | grep -q "node@"; then
        echo "Installing Node.js (latest) via Volta..."
        volta install node@latest
        echo "Node.js installed successfully."
    else
        echo "Node.js is already installed via Volta."
    fi
fi

# Install Claude Code CLI
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code CLI..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://claude.ai/install.sh | bash
    echo "Claude Code CLI installed successfully."
else
    echo "Claude Code CLI is already installed."
fi

# ============================================================
# Shell configuration (must be last)
# ============================================================

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    echo "zsh is now the default shell. Please log out and log back in for the change to take effect."
else
    echo "zsh is already the default shell."
fi
