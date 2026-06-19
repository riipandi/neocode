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

### Uninstall Neovim from Brew

```sh
brew uninstall neovim
```

### Neovim 0.12+ (stable)

```sh
curl -fSL https://github.com/neovim/neovim/releases/download/stable/nvim-macos-arm64.tar.gz | tar xz
xattr -c ./nvim-macos-arm64/ && sudo cp -R ./nvim-macos-arm64/* /usr/local/ && rm -fr nvim-macos-arm64
```

### Neovim 0.12+ (nightly)

```sh
curl -fSL https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz | tar xz
xattr -c ./nvim-macos-arm64/ && sudo cp -R ./nvim-macos-arm64/* /usr/local/ && rm -fr nvim-macos-arm64
```

### LSP & Formatters

```sh
brew install ripgrep fd luarocks taplo stylua rust-analyzer
brew install bash-language-server yaml-language-server
brew install oxlint oxfmt deno
```

```sh
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono font-jetbrains-mono-nerd-font
brew install --cask font-maple-mono font-maple-mono-nf
brew install btop chafa markdownlint-cli serpl
brew install jesseduffield/lazygit/lazygit
```

## Quick Start

### Clean previous configuration (if any)

```sh
rm -fr ~/.config/nvim/nvim-pack-lock.json
rm -fr ~/.local/share/nvim
rm -fr ~/.local/state/nvim
rm -fr ~/.cache/nvim
```

### Clone the starter

```sh
npx tiged https://github.com/riipandi/neocode ~/.config/nvim
```

### Terminal Configuration

```sh
ln -s ~/.config/nvim/ghostty ~/.config/ghostty/config
ln -s ~/.config/nvim/starship.toml ~/.config/starship.toml
```

## Supported Languages

| Language         | LSP             | Treesitter   | Formatter         |
|------------------|-----------------|--------------|-------------------|
| TypeScript/React | ts_ls + oxlint  | tsx, js      | oxfmt             |
| Tailwind CSS     | tailwindcss     | css          | oxfmt             |
| Lit              | ts_ls           | lit          | oxfmt             |
| Astro            | astro           | astro        | oxfmt             |
| Rust             | rust-analyzer   | rust         | rustfmt           |
| Go               | gopls (go.nvim) | go           | gofumpt (go.nvim) |
| Elixir/Phoenix   | elixirls        | elixir, heex | mix               |
| Zig              | zls             | zig          | zigfmt            |
| SQL (PG/SQLite)  | sqls            | sql          | sql-formatter     |
| Protobuf         | buf_ls          | proto        | buf               |
| Terraform        | terraform-ls    | hcl          | terraform         |
| Justfile         | -               | just         | -                 |

## Dependencies (Plugins)

| Plugin                   | Description                                             |
|--------------------------|---------------------------------------------------------|
| **snacks.nvim**          | All-in-one UI utilities (picker, explorer, etc.)        |
| **noice.nvim**           | Cmdline UI replacement (floating popup)                 |
| **nui.nvim**             | UI component library for noice                          |
| **blink.cmp**            | Code completion with snippet support                    |
| **friendly-snippets**    | Snippet collection                                      |
| **lazydev.nvim**         | Neovim development                                      |
| **colorful-menu.nvim**   | Colorful completion menus                               |
| **nvim-autopairs**       | Auto-close brackets and pairs                           |
| **todo-comments.nvim**   | Highlight TODO comments                                 |
| **urlview.nvim**         | Open URLs from text files                               |
| **cloak.nvim**           | Blur lines for sensitive info                           |
| **conform.nvim**         | Async code formatting                                   |
| **nvim-treesitter**      | Syntax highlighting                                     |
| **trouble.nvim**         | Pretty diagnostics UI                                   |
| **fff.nvim**             | Ripgrep/fzf replacement for file & grep search          |
| **ray-x/go.nvim**        | Go development toolkit (LSP, formatting, testing)       |
| **miniharp.nvim**        | Quick file marks; snacks.picker UI; noice notifications |
| **lsp_signature.nvim**   | LSP signature help                                      |
| **fidget.nvim**          | LSP progress indicator                                  |
| **nvim-lspconfig**       | LSP configuration                                       |
| **mason.nvim**           | LSP package manager                                     |
| **mason-lspconfig**      | Mason LSP server config helper                          |
| **mason-tool-installer** | Automatic tool installation                             |
| **gitsigns.nvim**        | Git signs in gutter                                     |
| **which-key.nvim**       | Keybinding helper                                       |
| **lualine.nvim**         | Statusline                                              |
| **plenary.nvim**         | Lua utility library (dependency)                        |

## Custom Commands

| Command                | Description                                                                                                       |
|------------------------|-------------------------------------------------------------------------------------------------------------------|
| `:MasonPkg [category]` | Browse and manage Mason packages via snacks.picker (e.g. `:MasonPkg LSP`, `:MasonPkg Formatter`, `:MasonPkg all`) |
| `:CleanNvim`           | Clear nvim cache and `nvim-pack-lock.json` for fresh plugin regeneration                                          |
| `:CleanNvim`           | Clear nvim cache and `nvim-pack-lock.json` for fresh plugin regeneration                                          |
| `:Format [N]`          | Format the current buffer (optionally to line N)                                                                  |
| `:Update`              | Update all plugins via `vim.pack.update()`                                                                        |
| `:LspRestart`          | Restart all attached LSP clients                                                                                  |
| `:HealthCheck`         | Run health check (Neovim version, required tools, LSP, pack-lock)                                                 |
| `:ReloadConfig`        | Reload Neovim config without restarting                                                                           |

## Features

- **Custom file explorer** via `snacks.explorer` with hjkl navigation, Shift+Arrow scroll, file operations (c/p/m/d/D/y/Y/r/a), and Vim-style editor focus preservation when closing buffers
- **MasonPkg picker** for managing LSP/formatter/linter packages with category filtering, preview, and batch install/uninstall
- **Miniharp file marks** integrated with snacks.picker (no native floating window; noice notifications for all status messages)
- **Native LSP and Tool installer** via mason-registry, mason-lspconfig, and mason-tool-installer
- **Consistent UI** through noice.nvim, snacks.notifier, and snacks.picker — all status messages, dialogs, and pickers share the same look
- **Telescope-style find files** via fff.nvim (Rust binary, ripgrep/fzf replacement) |
- **LSP action toggles** (`<leader>li/ld/lf/ls/lI`) for inlay hints, diagnostics, format on save, smooth scroll, and client info |
- **Modular architecture** — each file under `lua/` has single responsibility (e.g. `core_keymaps/explorer.lua` only handles file explorer keymaps) |

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
