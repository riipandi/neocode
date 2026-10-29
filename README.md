# Neovim Configuration

```
                            ▄
█▀▀▄ █▀▀█ █▀▀█ █▀▀▀ █▀▀█ █▀▀█ █▀▀█
█  █ █▀▀▀ █  █ █    █  █ █  █ █▀▀▀
▀  ▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀
```

Personal Neovim configuration for Aris Ripandi ([@riipandi][riipandi]), derived
from [Kickstart.nvim][kickstart-nvim]. Plugins are installed with Neovim's own
`vim.pack` — there is no plugin manager — and pinned in
`nvim-pack-lock.json`.

Keybindings: [KEYMAP.md](./KEYMAP.md).

## Requirements

- Neovim 0.12 or newer (`vim.pack`, `vim.lsp.config`, `vim.ui.open`).
- A terminal that forwards modified keys as their own keys: Shift+Enter,
  Option+Enter and Option+Shift+Enter are used for folding. Ghostty, kitty and
  wezterm do this through the kitty keyboard protocol, which Neovim enables
  automatically. `:KeyProbe` reports what Neovim actually receives.
- A Nerd Font (`vim.g.have_nerd_font = true` is set).

Optional, per feature:

```sh
brew install ripgrep fd lazygit swp btop mactop
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono font-jetbrains-mono-nerd-font
```

LSP servers, formatters and linters come from Mason (`:Mason`), not from Homebrew.

## Install

```sh
npx tiged https://github.com/riipandi/neocode ~/.config/nvim
```

Start Neovim. `vim.pack` installs the pinned plugins; Mason installs the tools
listed in `lua/plugin_mason.lua` (LSP servers, formatters, tree-sitter-cli).
Check the result with `:checkhealth` and `:HealthCheck`.

Terminal and prompt configs live in this repo too:

```sh
ln -s ~/.config/nvim/ghostty ~/.config/ghostty/config
ln -s ~/.config/nvim/starship.toml ~/.config/starship.toml
```

To start over: `:CleanNvim` (drops `nvim-pack-lock.json` and the cache
directory), or delete `~/.local/share/nvim`, `~/.local/state/nvim` and
`~/.cache/nvim`.

## Layout

| Path                                     | Contents                                                    |
| ---------------------------------------- | ----------------------------------------------------------- |
| `init.lua`                               | Options, leader keys, module load order                     |
| `lua/core_*.lua`                         | Theme, LSP, autocmds, commands, health, plugin setup, scroll |
| `lua/core_keymaps/*.lua`                 | Keymaps by topic (`general`, `scroll`, `folds`, `buffer`, `quit`, `tools`, `cmdline`, `explorer`, `picker`, `ai`, `undo`) |
| `lua/plugin_*.lua`                       | One file per plugin group (editor, completion, treesitter, vcs, lsp tooling, markdown, AI) |
| `lua/language_*.lua`                     | Per-language LSP/formatter setup (Rust, TypeScript, Go, Elixir, Zig, SQL, Terraform, Protobuf, Astro, Lit, Tailwind) |
| `lua/mistral-codestral/`                 | Local fork of the Codestral client                          |
| `lua/mason_pkg/`                         | Mason package picker                                        |
| `lua/snacks/`                            | Picker layouts and the swpui wrapper                        |
| `ghostty/`, `starship.toml`, `rio/`       | Terminal emulator and prompt configuration                  |
| `KEYMAP.md`, `nvim-pack-lock.json`       | Keymap reference and plugin pin file                        |

Load order matters in one place: `core_scroll` is required before
`snacks.nvim`, so its `WinScrolled` handler runs first and the fold/scroll
correction happens before the scroll animation is set up.

## Behaviour notes

These are the deliberate choices that differ from a stock configuration.

- **Dialogs keep your mode.** `vim.ui.select` is backed by the snacks picker;
  confirmations open with the list focused, so you stay in normal mode (`j`/`k`,
  `<CR>`, `<Esc>`). Dialogs opened from insert mode keep the input focused.
- **Folds are smart.** `<S-CR>` toggles the block around the cursor from any row,
  not only from a fold header; on a top-level row it folds the nearest block and
  leaves the cursor in place. `<M-S-CR>` toggles every fold. Folds come from the
  treesitter foldexpr, which `init.lua` sets globally (Neovim only does it for
  lua buffers).
- **Gutter stays quiet.** Git hunks as `▎` bars, errors `󰅚`, warnings `󰀪`.
  Info/hint diagnostics, markdown preview signs and the `~` end-of-buffer marker
  are not drawn. `signcolumn = yes:1` keeps the column reserved so text never
  shifts.
- **Scrolling is native.** `scrolloff = 0`, so the cursor is never dragged by
  view scrolling; `<S-Up>`/`<S-Down>` and `}`/`{` move half a page like
  `<C-u>`/`<C-d>`. `snacks.scroll` animates the viewport at 45 ms per line.
- **Markdown preview is foreground-first.** Rendered in normal/visual/command
  modes only; insert mode shows the raw source with `conceallevel = 0`. Code
  blocks keep a background band, headings have neither background nor sign,
  inline code is soft purple `#9976cb` without a background, links are soft blue
  `#498bc9` without an icon, and the sign column stays empty.
- **No failed writes.** Format-on-save uses conform with flat fallback chains
  (`stop_after_first`); `vim.b.disable_autoformat = true` skips a buffer (set for
  `toml`).
- **Commands that lie are gone.** `:Format`/`:FormatCode`/`<leader>fm` all use
  conform, `:LspRestart` actually restarts clients, `:ReloadConfig` reloads all
  config modules (not just `core_*`).

## Language support

LSP servers are configured in `lua/core_lsp.lua` and `lua/language_*.lua`,
formatters in `lua/plugin_editor.lua` (conform). Servers marked *on demand* are
enabled when the matching filetype opens.

| Language              | LSP                              | Formatter            |
| --------------------- | -------------------------------- | -------------------- |
| Lua (this config)     | `lua_ls` + lazydev types         | `stylua`             |
| TypeScript / JS / JSX | `ts_ls`, `oxlint` (`deno` when a `deno.json` exists) | `oxfmt` → `prettierd` → `prettier` |
| Astro / Vue / Svelte / Lit | `ts_ls`, `oxlint`; `astro` on demand | `oxfmt` → `prettier` |
| Tailwind CSS          | `tailwindcss`                    | —                    |
| Rust                  | `rust-analyzer` (clippy on save), crates.nvim | `rustfmt` |
| Go                    | `gopls` via go.nvim, `golangci-lint` | `goimports` on save (go.nvim) |
| Elixir / Phoenix      | `elixirls`                       | `mix format`         |
| Zig                   | `zls`                            | `zig fmt`            |
| SQL                   | `sqls`                           | `sql-formatter`      |
| Protobuf              | `buf_ls`                         | —                    |
| Terraform / HCL       | `terraform_ls`                   | `terraform fmt`      |
| Python                | `pylsp`                          | `black`              |
| Shell                 | `bashls`                         | `shfmt`              |
| HTML                  | `html`, `superhtml` (when installed) | —                |
| CSS / JSON / Docker   | `cssls`, `jsonls`, `dockerls`    | —                    |
| YAML / TOML / TeX     | `yamlls`, `taplo`, `texlab`      | —                    |
| Markdown              | render-markdown preview          | —                    |

Tree-sitter parsers: astro, bash, css, diff, eex, elixir, go, hcl, heex, html,
javascript, jsdoc, json, json5, just, lua, luadoc, luap, markdown,
markdown_inline, python, query, regex, rust, sql, svelte, toml, tsx, typescript,
vim, vimdoc, xml, yaml, zig. They are installed with
`require("nvim-treesitter").install()` and compiled with `tree-sitter-cli` from
Mason.

## Plugins

| Plugin                       | Role                                                        |
| ---------------------------- | ----------------------------------------------------------- |
| **snacks.nvim**              | Explorer, picker, notifier, indent, terminal, lazygit, input, scope |
| **fff**                      | File and grep search (Rust binary)                          |
| **noice.nvim** + **nui.nvim**| Floating cmdline and message routing                        |
| **blink.cmp** + **blink.lib**| Completion (`lua` fuzzy engine; capabilities for every LSP) |
| **friendly-snippets**        | Snippet source for blink.cmp                                |
| **lazydev.nvim**             | Neovim API types for `lua_ls`                               |
| **colorful-menu.nvim**       | Completion menu highlighting                                |
| **nvim-treesitter**          | Syntax highlighting, folds, indent                          |
| **render-markdown.nvim**     | Inline markdown preview                                     |
| **conform.nvim**             | Formatting (save and manual)                                |
| **nvim-lspconfig**           | LSP configs used by `vim.lsp.config`                        |
| **mason.nvim**, **mason-lspconfig**, **mason-tool-installer** | Tool installation |
| **lsp_signature.nvim**, **fidget.nvim** | Signature help and LSP progress                 |
| **trouble.nvim**             | Diagnostics list                                            |
| **gitsigns.nvim**            | Gutter hunks and hunk actions                               |
| **miniharp.nvim**            | File marks (picker UI supplied by snacks)                   |
| **multicursor.nvim**         | Multiple cursors                                            |
| **nvim-autopairs**           | Bracket and quote pairing                                   |
| **todo-comments.nvim**, **urlview.nvim**, **cloak.nvim** | TODO highlights, URL list, secret masking |
| **which-key.nvim**           | Keymap hints                                                |
| **lualine.nvim**, **mini.icons**, **nvim-web-devicons** | Statusline and icons          |
| **transparent.nvim**         | Transparent background groups                               |
| **go.nvim**, **crates.nvim** | Go and Cargo tooling                                        |
| **plenary.nvim**             | Lua utility library (dependency)                            |

`mdkite.nvim` and `kitehost.nvim` are still pinned in `nvim-pack-lock.json` but
nothing requires them; the markdown preview is render-markdown.

Plugin management: `:Update` or `<leader>pu` runs `vim.pack.update()`; the lock
file records the commit each plugin is pinned to.

## Commands

| Command                              | Purpose                                             |
| ------------------------------------ | --------------------------------------------------- |
| `:MasonPkg [category]`               | Mason picker with category cycling (`LSP`, `Formatter`, `Linter`, `DAP`, `Runtime`, `Compiler`, `All`) |
| `:Format`, `:FormatCode`             | Format the buffer with conform                      |
| `:LspInfo`, `:LspRestart`            | Show or restart LSP clients                         |
| `:ConformInfo`                       | Which formatters apply to this buffer               |
| `:Update`                            | Update plugins                                      |
| `:ReloadConfig`                      | Reload config modules without restarting            |
| `:CleanNvim`                         | Reset cache and lock file                           |
| `:HealthCheck`                       | Version, tools, LSP, pack-lock                      |
| `:checkhealth kickstart.nvim`        | Neovim version and required executables             |
| `:KeyProbe`                          | Show the notation Neovim receives for the next key  |
| `:MarkdownOpenLink`                  | Open the link under the cursor                      |
| `:MistralCodestralAuth`              | Auth picker (subcommands `status`, `set`, `clear`, `validate`) |
| `:MistralCodestralComplete`, `:MistralCodestralToggle` | Manual completion, on/off switch  |
| `:MistralCodestralVirtualComplete`, `:MistralCodestralVirtualClear` | Ghost preview control |
| `:MistralCodestralHealth`, `:MistralCodestralCommitMsg[!]` | Health report, commit message from the diff |

## AI completion (Mistral Codestral)

`lua/mistral-codestral/` is a local fork of
[jrollin/mistral-codestral.nvim](https://github.com/jrollin/mistral-codestral.nvim)
wired to blink.cmp only (no nvim-cmp code paths). Differences from upstream:

- API key from `CODESTRAL_API_KEY`, then `MISTRAL_API_KEY`, then a system
  keyring entry; `api_key` can also be passed to `setup()`.
- Current Neovim APIs: `vim.uv` instead of `vim.loop`, `vim.json` instead of
  `vim.fn.json_*`, `vim.treesitter.get_node` instead of `ts_utils`.
- blink.cmp provider registered with `add_source_provider`, with cancel support.
- Ghost-text preview with `<M-l>` / `<C-Right>` / `<C-Down>` / `<M-]>` / `<M-[>`
  / `<C-c>`, plus `<leader>ie` to explain the selected completion.

```sh
export CODESTRAL_API_KEY="your-key-here"
```

The lualine status component shows the current state (`─ idle`,
`◐ waiting 1.2s`, `● ready`, `✖ error`) and runs `:MistralCodestralToggle` when
clicked. Three functions drive it: `status()`, `status_string()` and
`status_label()` on `mistral-codestral.virtual_text`.

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
[riipandi]: https://x.com/intent/follow?screen_name=riipandi
