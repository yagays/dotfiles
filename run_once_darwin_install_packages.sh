#!/bin/bash
# Install Homebrew and packages on macOS

# Exit if not macOS
if [[ "$(uname)" != "Darwin" ]]; then
    exit 0
fi

# Install Xcode Command Line Tools if not installed
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait for installation to complete
    echo "Please complete the Xcode Command Line Tools installation, then press Enter to continue..."
    read -r
else
    echo "Xcode Command Line Tools are already installed."
fi

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo "Homebrew installed successfully."
else
    echo "Homebrew is already installed."
fi

# Packages to install via brew
BREW_PACKAGES=(
    1password-cli
    awscli
    chezmoi
    emacs
    fzf
    gh
    ghq
    gibo
    git
    git-lfs
    go
    htop
    hugo
    tig
    tmux
    tree
    wget
)

# Install packages
echo "Installing brew packages..."
for package in "${BREW_PACKAGES[@]}"; do
    if ! brew list "$package" &> /dev/null; then
        echo "Installing $package..."
        brew install "$package"
    else
        echo "$package is already installed."
    fi
done

# Install uv (Python package manager)
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "uv installed successfully."
else
    echo "uv is already installed."
fi

# Run gh auth login if gh was just installed
if command -v gh &> /dev/null && ! gh auth status &> /dev/null; then
    echo "Running gh auth login..."
    gh auth login
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

echo "macOS package installation completed."
