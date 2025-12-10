# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

## Installation

```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply yagays
```

## Usage

### Apply dotfiles

```sh
chezmoi apply
```

### Edit a dotfile

```sh
chezmoi edit ~/.zshrc
```

### Update from remote repository

```sh
chezmoi update
```

### Add a new dotfile

```sh
chezmoi add ~/.config/xxx
```

### List managed files

```sh
chezmoi managed
```

## Managed files

- `.zshrc`
- `.emacs`
- `.gitconfig`
- `.screenrc`
- `.tigrc`
- `.tmux.conf`
- `.claude/`
- `.config/`
