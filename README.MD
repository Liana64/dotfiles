## Installation

Add an init hook to fish.config

```sh
source $HOME/.config/fish/conf.d/.env
````

Stow desired packages

```sh
stow -t $HOME <Package>
```

**Packages**
- [GNU Stow](https://git.savannah.gnu.org/cgit/stow.git)
- [Eza](https://github.com/eza-community/eza)
- [bat](https://github.com/sharkdp/bat)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [alacritty](https://github.com/alacritty/alacritty)
- [starship](https://github.com/starship/starship)
- [tmux](https://github.com/tmux/tmux)
- [fish-shell](https://github.com/fish-shell/fish-shell)
- [neovim](https://github.com/neovim/neovim)
- [fzf](https://github.com/junegunn/fzf)
- [tldr](https://github.com/tldr-pages/tldr)
- [k9s](https://github.com/derailed/k9s)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace)

## Features

Adds a number of useful features and aliases, built on fish shell, including:

- Terminal Kagi search with [s](https://github.com/zquestz/s) (compile to "se")
- Bang bang ("!!") and ctrl-del/ctrl-] support
- Make and cd to a temporary directory ("mktmp")
- Replaces defaults ("ls","cat") with colorful rust variations
- josean-dev's [nvim config](https://github.com/josean-dev/dev-environment-files)
- Management of SSH agents (type `ssha` and `ssh-add-all` or `ssharm` to clear)
- Construction & deconstruction of pre-configured tmux workspaces (type `tws` and `tks`)
- Andrea Colangelo's fortune-mod displayed with each new window
- News from the Brutalist Report (type `news`)
- Weather reports from Igor Chubin's "wttr.in" (type `weather`)
- Aliases for working with a terminal (type `i` or `l`)
- Aliases for easy use of kubectl & docker (type `k` or `dps`)
- Aliases for easy use of tmux (type `t`)

## Variables 

Variable | Description
-- | --
| LN_DEBUG | Show debug messages when `true`
| LN_PATH | Automatically set. Location of fish conf.d folder
| LN_CITY | City for weather reports
| LN_SSH_AGENTS | A directory containing SSH keys to load, e.g. $HOME/.ssh/agents/
| LN_TMUX | A list of tmux workspaces to create, parsed in order & comma-separated

## Quick commands

- Quickly edit dotfiles with `editcfg`
- Reload the config with `reloadcfg`

## Links

- [Alacritty themes](https://github.com/alacritty/alacritty-theme/tree/master/themes)
