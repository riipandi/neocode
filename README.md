# 🎒 Neovim Configuration

This is a personal Neovim configuration for Aris Ripandi ([@riipandi][riipandi]).

This configuration based on [Kickstart.nvim][kickstart-nvim], a starting point
for your own configuration. The goal is that you can read every line of code,
top-to-bottom, understand what your configuration is doing, and modify it to
suit your needs. If you don't know anything about Lua, I recommend taking some
time to read [through a guide][learnxinyminutes].

## Prerequisites

### Neovim 0.12+ nightly
```sh
brew uninstall neovim

curl -#L https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz | tar xz
sudo cp -R ./nvim-macos-arm64/* /usr/local/ && rm -fr nvim-macos-arm64
```

```sh
brew install ripgrep fd luarocks taplo stylua rust-analyzer
brew install bash-language-server yaml-language-server python-lsp-server
brew install --cask rio

brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono font-jetbrains-mono-nerd-font
brew install --cask font-maple-mono font-maple-mono-nf
  
brew install markdownlint-cli viu chafa
brew install jesseduffield/lazygit/lazygit
brew install jstkdng/programs/ueberzugpp
```

## IDE Setup

### Cleanup previous configuration

```sh
rm -fr ~/.config/nvim/nvim-pack-lock.json
rm -fr ~/.local/share/nvim
rm -fr ~/.local/state/nvim
rm -fr ~/.cache/nvim
```

## Dependencies (Plugins)

| Plugin          | Description         |
|-----------------|---------------------|
| nvim-treesitter | Syntax highlighting |
| gitsigns.nvim   | Git signs in gutter |
| lazygit.nvim    | LazyGit integration |
| nvim-tree.lua   | File explorer       |
| fzf-lua         | Fuzzy finder        |
| telescope.nvim  | Picker UI           |
| blink.cmp       | Code completion     |
| neoscroll.nvim  | Smooth scrolling    |
| which-key.nvim  | Keybinding helper   |
| noice.nvim      | Better cmdline UI   |
| nvim-notify     | Notification system |
| miniharp.nvim   | Quick file marks    |

## Keybindings

### Navigation

| Shortcut       | Action                                 |
|----------------|----------------------------------------|
| `Ctrl+E`       | Switch focus between explorer ↔ editor |
| `Ctrl+Shift+E` | Toggle file explorer                   |
| `Ctrl+B`       | Show buffer list (Telescope)           |
| `Ctrl+P`       | Find files (fzf-lua)                   |
| `Ctrl+L`       | Show marks list (miniharp)             |
| `Ctrl+N`       | Next mark                              |
| `Ctrl+Shift+M` | Previous mark                          |

### Editor

| Shortcut       | Action                                |
|----------------|---------------------------------------|
| `Ctrl+G`       | Go to line (format: `10` atau `10:5`) |
| `Ctrl+Shift+G` | Toggle LazyGit                        |
| `Ctrl+X`       | Close buffer                          |
| `Ctrl+Q`       | Quit Neovim                           |
| `Ctrl+\`       | Split vertical                        |
| `Ctrl+Shift+\` | Split horizontal                      |

### Scrolling

| Shortcut       | Action                  |
|----------------|-------------------------|
| `Ctrl+Shift+J` | Scroll down (half page) |
| `Ctrl+Shift+K` | Scroll up (half page)   |
| `Alt+J`        | Move line down          |
| `Alt+K`        | Move line up            |

### Window

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+[` | Previous window |
| `Ctrl+Alt+]` | Next window |
| `Ctrl+Alt+=` | Increase width |
| `Ctrl+Alt+-` | Decrease width |
| `Ctrl+Shift+=` | Increase height |
| `Ctrl+Shift+-` | Decrease height |

### Search

| Shortcut      | Action                            |
|---------------|-----------------------------------|
| `Space` + `n` | Next search result (centered)     |
| `Space` + `N` | Previous search result (centered) |
| `Space` + `c` | Clear search highlights           |

### Git

| Shortcut       | Action         |
|----------------|----------------|
| `Space` + `gg` | Toggle LazyGit |
| `Space` + `gs` | Git status     |
| `Space` + `gp` | Git push       |

## Clone the starter

```sh
npx tiged https://github.com/riipandi/neovim-config ~/.config/nvim
```

## Inspirations

- https://github.com/LazyVim/starter
- https://github.com/newtoallofthis123/nvim-config
- https://www.youtube.com/watch?v=55lvdPYr4j0
- https://www.youtube.com/watch?v=AAkrmfkC1L4
- https://github.com/radleylewis/nvim-lite
- https://vieitesss.github.io/posts/Neovim-new-config
- https://github.com/kezhenxu94/dotfiles/tree/main/config/nvim

<!-- link reference definition -->
[kickstart-nvim]: https://github.com/nvim-lua/kickstart.nvim
[learnxinyminutes]: https://learnxinyminutes.com/docs/lua
[riipandi]: https://x.com/intent/follow?screen_name=riipandi
