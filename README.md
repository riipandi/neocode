# Neovim Configuration

```
                            ▄
█▀▀▄ █▀▀█ █▀▀█ █▀▀▀ █▀▀█ █▀▀█ █▀▀█
█  █ █▀▀▀ █  █ █    █  █ █  █ █▀▀▀
▀  ▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀
```

This is a personal Neovim configuration for Aris Ripandi ([@riipandi][riipandi]).

This configuration is based on [Kickstart.nvim][kickstart-nvim], a starting point
for your own configuration. The goal is that you can read every line of code,
top-to-bottom, understand what your configuration is doing, and modify it to
suit your needs. If you don't know anything about Lua, I recommend taking some
time to read [through a guide][learnxinyminutes].

## Prerequisites

### Neovim 0.12+
```sh
brew uninstall neovim

# Stable
curl -#L https://github.com/neovim/neovim/releases/download/v0.12.0/nvim-macos-arm64.tar.gz | tar xz

# Nightly 
curl -#L https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz | tar xz

# Install and clean
xattr -c ./nvim-macos-arm64/ && sudo cp -R ./nvim-macos-arm64/* /usr/local/ && rm -fr nvim-macos-arm64
```

### Core Tools
```sh
# LSP & Formatters
brew install ripgrep fd luarocks taplo stylua rust-analyzer
brew install bash-language-server yaml-language-server
brew install oxlint oxfmt deno

# Dev Tools
brew install jesseduffield/lazygit/lazygit
```

### Optional Tools (Recommended)
```sh
# Fonts
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono font-jetbrains-mono-nerd-font
brew install --cask font-maple-mono font-maple-mono-nf

# System Monitoring and image preview
brew install btop chafa

# Utilities
brew install markdownlint-cli serpl
```

## Quick Start

```sh
# Clean previous configuration (if any)
rm -fr ~/.config/nvim/nvim-pack-lock.json
rm -fr ~/.local/share/nvim
rm -fr ~/.local/state/nvim
rm -fr ~/.cache/nvim

# Clone the starter
npx tiged https://github.com/riipandi/neocode ~/.config/nvim
```

## Supported Languages

| Language         | LSP            | Treesitter   | Formatter     |
|------------------|----------------|--------------|---------------|
| TypeScript/React | ts_ls + oxlint | tsx, js      | oxfmt         |
| Tailwind CSS     | tailwindcss    | css          | oxfmt         |
| Lit              | ts_ls          | lit          | oxfmt         |
| Astro            | astro          | astro        | oxfmt         |
| Rust             | rust-analyzer  | rust         | rustfmt       |
| Go               | gopls (go.nvim)  | go           | gofumpt (go.nvim) |
| Elixir/Phoenix   | elixirls       | elixir, heex | mix           |
| Zig              | zls            | zig          | zigfmt        |
| SQL (PG/SQLite)  | sqls           | sql          | sql-formatter |
| Protobuf         | buf_ls         | proto        | buf           |
| Terraform        | terraform-ls   | hcl          | terraform     |
| Justfile         | -              | just         | -             |

## Dependencies (Plugins)

| Plugin                 | Description                                      |
|------------------------|--------------------------------------------------|
| **snacks.nvim**        | All-in-one UI utilities (picker, explorer, etc.) |
| **noice.nvim**         | Cmdline UI replacement (floating popup)          |
| **nui.nvim**           | UI component library for noice                   |
| **blink.cmp**          | Code completion with snippet support             |
| **friendly-snippets**  | Snippet collection                               |
| **lazydev.nvim**       | Neovim development                               |
| **colorful-menu.nvim** | Colorful completion menus                        |
| **nvim-autopairs**     | Auto-close brackets and pairs                    |
| **todo-comments.nvim** | Highlight TODO comments                          |
| **urlview.nvim**       | Open URLs from text files                        |
| **cloak.nvim**         | Blur lines for sensitive info                    |
| **conform.nvim**       | Async code formatting                            |
| **nvim-treesitter**    | Syntax highlighting                              |
| **fff.nvim**           | Ripgrep/fzf replacement for file & grep search   |
| **ray-x/go.nvim**       | Go development toolkit (LSP, formatting, testing) |
| **lsp_signature.nvim** | LSP signature help                               |
| **trouble.nvim**       | Pretty diagnostics UI                            |
| **fidget.nvim**        | LSP progress indicator                           |
| **nvim-lspconfig**     | LSP configuration                                |
| **mason.nvim**         | LSP package manager                              |
| **gitsigns.nvim**      | Git signs in gutter                              |
| **which-key.nvim**     | Keybinding helper                                |
| **lualine.nvim**       | Statusline                                       |

## Keybindings

See [KEYMAP.md](./KEYMAP.md) for complete keybindings reference.

## License

See [LICENSE](./LICENSE) for details.

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
