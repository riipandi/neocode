# 🎒 Neovim Configuration

<img src="./screenshot1.png" alt="Neocode" height="520" />

This is a personal Neovim configuration for Aris Ripandi ([@riipandi][riipandi]).

This configuration is based on [Kickstart.nvim][kickstart-nvim], a starting point
for your own configuration. The goal is that you can read every line of code,
top-to-bottom, understand what your configuration is doing, and modify it to
suit your needs. If you don't know anything about Lua, I recommend taking some
time to read [through a guide][learnxinyminutes].

## Prerequisites

### Neovim 0.12+ nightly
```sh
brew uninstall neovim

curl -#L https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz | tar xz
xattr -c ./nvim-macos-arm64/ && sudo cp -R ./nvim-macos-arm64/* /usr/local/ && rm -fr nvim-macos-arm64
```

```sh
brew install ripgrep fd luarocks taplo stylua rust-analyzer serpl
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

| Plugin                        | Description                                      |
|-------------------------------|--------------------------------------------------|
| **snacks.nvim**               | All-in-one UI utilities (picker, explorer, etc.) |
| **noice.nvim**                | Cmdline UI replacement (floating popup)          |
| **nui.nvim**                  | UI component library for noice                   |
| **blink.cmp**                 | Code completion with snippet support             |
| **friendly-snippets**         | Snippet collection                               |
| **lazydev.nvim**              | Neovim development                               |
| **colorful-menu.nvim**        | Colorful completion menus                        |
| **nvim-autopairs**            | Auto-close brackets and pairs                    |
| **todo-comments.nvim**        | Highlight TODO comments                          |
| **urlview.nvim**              | Open URLs from text files                        |
| **cloak.nvim**                | Blur lines for sensitive info                    |
| **conform.nvim**              | Slow/conforming async formatting                 |
| **miniharp.nvim**             | Quick file marks and navigation                  |
| **plenary.nvim**              | Utility functions                                |
| **lualine.nvim**              | Statusline for fancy status bar                  |
| **nvim-web-devicons**         | File type icons                                  |
| **mini.icons**                | Icon provider                                    |
| **mason.nvim**                | LSP package manager                              |
| **mason-lspconfig.nvim**      | LSP configuration for Mason                      |
| **mason-tool-installer.nvim** | Tool installer for Mason                         |
| **nvim-treesitter**           | Syntax highlighting                              |
| **lsp_signature.nvim**        | LSP signature help                               |
| **trouble.nvim**              | Pretty diagnostics UI                            |
| **fidget.nvim**               | LSP progress indicator                           |
| **nvim-lspconfig**            | LSP configuration                                |
| **gitsigns.nvim**             | Git signs in gutter                              |
| **which-key.nvim**            | Keybinding helper                                |
| **opencode.nvim**             | AI code assistant                                |
| **serpl**                     | Search & replace TUI (VSCode-like)               |

## OpenCode Theme

```sh
mkdir -p ~/.config/opencode/themes/
touch ~/.config/opencode/themes/atomizer-island.json
cat ~/.config/nvim/opencode-theme.json \
  > ~/.config/opencode/themes/atomizer-island.json
```

Documentation: https://opencode.ai/docs/themes

## Keybindings

See [KEYMAP.md](./KEYMAP.md) for complete keybindings reference.

## License

See [LICENSE](./LICENSE) for details.

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
- https://ricoberger.de/blog/posts/my-dotfiles/

<!-- link reference definition -->
[kickstart-nvim]: https://github.com/nvim-lua/kickstart.nvim
[learnxinyminutes]: https://learnxinyminutes.com/docs/lua
[riipandi]: https://x.com/intent/follow?screen_name=riipandi
