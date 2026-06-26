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
brew install btop chafa markdownlint-cli swpui
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
| **mistral-codestral (fork)** | AI autocompletion via Mistral Codestral (FIM, blink.cmp only) |
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

| Command                              | Description                                                                                                       |
|--------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| `:MasonPkg [category]`               | Browse and manage Mason packages via snacks.picker (e.g. `:MasonPkg LSP`, `:MasonPkg Formatter`, `:MasonPkg all`) |
| `:MistralCodestralComplete`          | Request an inline Codestral completion (FIM) for the current cursor position                                      |
| `:MistralCodestralToggle`            | Globally enable/disable Codestral completions                                                                      |
| `:MistralCodestralAuth ...`          | Manage the API key (`status`, `set`, `clear`, `validate`)                                                          |
| `:MistralCodestralVirtualComplete`   | Manually trigger the ghost-text preview                                                                            |
| `:MistralCodestralVirtualClear`      | Clear any active ghost-text preview                                                                                |
| `:MistralCodestralHealth`            | Run the fork's :checkhealth-style report                                                                            |
| `:CleanNvim`                         | Clear nvim cache and `nvim-pack-lock.json` for fresh plugin regeneration                                          |
| `:Format [N]`                        | Format the current buffer (optionally to line N)                                                                  |
| `:Update`                            | Update all plugins via `vim.pack.update()`                                                                        |
| `:LspRestart`                        | Restart all attached LSP clients                                                                                  |
| `:HealthCheck`                       | Run health check (Neovim version, required tools, LSP, pack-lock)                                                 |
| `:ReloadConfig`                      | Reload Neovim config without restarting                                                                           |

## AI Autocompletion (Mistral Codestral)

A local fork of [jrollin/mistral-codestral.nvim](https://github.com/jrollin/mistral-codestral.nvim)
lives under `lua/mistral-codestral/` and ships its own `plugin_mistral_codestral.lua`.
It is optimized for this Neovim 0.12+ setup and uses **blink.cmp v1.6+** as the
sole completion engine — the upstream `nvim-cmp` source has been removed.

Key differences from upstream:

- **API key:** set `CODESTRAL_API_KEY` in your shell. `MISTRAL_API_KEY` is honored as a fallback, and you can also pass `api_key` in `setup()`.
- **Deprecated APIs replaced:** `vim.loop` → `vim.uv`, `vim.fn.json_encode/decode` → `vim.json.encode/decode`, `nvim-treesitter.ts_utils` → `vim.treesitter.get_node`.
- **blink.cmp source boilerplate:** proper `source.new(opts)` constructor and `get_completions(ctx, callback)` with cancel support.
- **No nvim-cmp code paths** — the `cmp_source_enhanced.lua` file is dropped entirely; the `completion_engine` config key is gone.
- **`virtual_text` ghost preview** kept (Windsurf-style) with default keymaps `M-l` / `C-Right` / `C-Down` / `M-]` / `M-[` / `C-c`.

Minimal setup (already wired in `plugin_mistral_codestral.lua`):

```sh
export CODESTRAL_API_KEY="your-key-here"
```

```lua
-- Plugin already loaded by init.lua; override defaults here if needed:
require("mistral-codestral").setup({
  model = "codestral-latest",
  max_tokens = 256,
  max_items = 3,        -- one full + first-line variant
  virtual_text = { enabled = true, idle_delay = 800, min_chars = 3 },
```lua
-- Plugin already loaded by init.lua; override defaults here if needed:
require("mistral-codestral").setup({
  model = "codestral-latest",
  max_tokens = 256,
  max_items = 3,        -- one full + first-line variant
  virtual_text = { enabled = true, idle_delay = 800, min_chars = 3 },
})
```

### Keymaps (which-key `<leader>i`)

| Key | Action |
|-----|--------|
| `<leader>ic` | Manual complete (`:MistralCodestralComplete`) |
| `<leader>it` | Toggle AI completions on/off |
| `<leader>iv` | Trigger ghost-text preview |
| `<leader>ix` | Clear ghost-text preview |
| `<leader>iA` | Auth manager (snacks picker) |
| `<leader>ih` | Health check |
| `<leader>ig` | Generate commit message from `git diff` |
| `<C-g>` (in insert mode, blink menu open) | AI-explain the selected item |

`<leader>i` was chosen because `<leader>m` is taken by miniharp file marks.

### Commands

| Command | Description |
|---------|-------------|
| `:MistralCodestralComplete` | Request an inline FIM completion for the current cursor position |
| `:MistralCodestralToggle` | Globally enable/disable Codestral completions |
| `:MistralCodestralAuth [sub]` | Open the snacks picker (no arg) or run a subcommand (`status`, `set`, `clear`, `validate`) |
| `:MistralCodestralVirtualComplete` / `:MistralCodestralVirtualClear` | Manually trigger/clear the ghost-text preview |
| `:MistralCodestralHealth` | Run the fork's :checkhealth-style report |
| `:MistralCodestralCommitMsg[!]` | Generate a Conventional Commit message from staged (default) or working-tree (`!`) changes |
| `:MistralExplainCompletion` | Ask Codestral to explain the currently selected blink.cmp item (opens floating markdown window) |

### Integrations

### Statusline

A custom lualine component shows what Mistral Codestral is doing right now. The label uses plain words and a colored icon so it is readable at a glance:

| State | Display (icon + text) | Color | Meaning |
|-------|------------------------|-------|---------|
| idle | `─ codestral-latest` | dim gray | plugin loaded, no request in flight |
| waiting | `◐ waiting 1.2s (function body)` | orange | API call in progress; `(...)` shows the inferred strategy |
| ready | `● ready` (or `● ready (2 of 3)`) | green | ghost-text completion is showing |
| error | `✖ error: <message>` | red | last request failed |

The component is also clickable: clicking it runs `:MistralCodestralToggle` to enable/disable completions, and the hover tooltip shows the full status (e.g. `Mistral Codestral: 1 completion(s) available [strategy: normal]`).

The status is driven by three functions on `mistral-codestral.virtual_text`:
- `M.status()` — raw table (state, strategy, model, current, total, last_error, …)
- `M.status_string()` — short single-token label (e.g. `◐ 1.2s`, `●`, `─`)
- `M.status_label()` — rich `{ text, icon, color, tooltip }` for statuslines

### Keymaps (which-key `<leader>i`)

| Key | Action |
|-----|--------|
| `<leader>ic` | Manual complete (`:MistralCodestralComplete`) |
| `<leader>it` | Toggle AI completions on/off |
| `<leader>iv` | Trigger ghost-text preview |
| `<leader>ix` | Clear ghost-text preview |
| `<leader>iA` | Auth manager (snacks picker) |
| `<leader>ih` | Health check |
| `<leader>ig` | Generate commit message from `git diff` |
| `<C-g>` (in insert mode, blink menu open) | AI-explain the selected item |

`<leader>i` was chosen because `<leader>m` is taken by miniharp file marks.

### Commands

| Command | Description |
|---------|-------------|
| `:MistralCodestralComplete` | Request an inline FIM completion for the current cursor position |
| `:MistralCodestralToggle` | Globally enable/disable Codestral completions |
| `:MistralCodestralAuth [sub]` | Open the snacks picker (no arg) or run a subcommand (`status`, `set`, `clear`, `validate`) |
| `:MistralCodestralVirtualComplete` / `:MistralCodestralVirtualClear` | Manually trigger/clear the ghost-text preview |
| `:MistralCodestralHealth` | Run the fork's :checkhealth-style report |
| `:MistralCodestralCommitMsg[!]` | Generate a Conventional Commit message from staged (default) or working-tree (`!`) changes |
| `:MistralExplainCompletion` | Ask Codestral to explain the currently selected blink.cmp item (opens floating markdown window) |

### Integrations

- **which-key:** `<leader>i` group in `plugin_whichkey.lua`
- **lualine:** Status component in `lualine_y` showing AI state (` * ` waiting, `1/1` completions) with orange/green color
- **snacks:** Auth manager picker (`Status` / `Set` / `Clear` / `Validate`)
- **blink.cmp:** Source provider registered via `add_source_provider`; the `<C-g>` keymap in insert mode triggers AI explain on the selected item
- **noice:** All `vim.notify` calls go through the existing noice integration automatically

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
