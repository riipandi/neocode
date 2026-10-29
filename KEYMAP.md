# Keymaps

## General

| Action                | WhichKey | Shortcut          |
| --------------------- | -------- | ----------------- |
| Quit all              | `q`      | `<leader>q`       |
| Quit all              | `qq`     | `<leader>qq`      |
| Quit all              |          | `<C-q>` / `<A-q>` |
| Close buffer or split |          | `<C-x>`           |
| Close all buffers     |          | `<leader>bW`      |
| Command palette       | `;`      | `<leader>;`       |
| Command palette (all) | `:`      | `<leader>:`       |
| Edit config           | `,`      | `<leader>,`       |

> **Note:** `<C-x>` keeps the file explorer open and shows a blank buffer when the last editor buffer is closed, instead of letting the explorer expand to full width.

## Dialogs

Confirmation dialogs (quit, unsaved buffer, Mason actions) open through
`vim.ui.select` with `focus = "list"`: the list is focused, so you stay in
normal mode — `j`/`k` to move, `<CR>` to choose, `<Esc>` to cancel. Nothing is
typed into the search field unless you press `/` (or `i`). Dialogs opened from
insert mode keep the input focused instead, so typing continues to work.

## Escape Key

| Action                | Shortcut | Description                                            |
| --------------------- | -------- | ------------------------------------------------------ |
| Close floating window | `<Esc>`  | Closes lazygit, picker, etc. (normal mode only)        |
| Clear search          | `<Esc>`  | Clears search highlights in a normal buffer            |

`<Esc>` is **not** mapped in terminal mode, so terminal programs (fzf, htop,
lazygit, ...) receive it. In a snacks terminal use `<Esc><Esc>` to leave.

## Buffer

| Action              | WhichKey | Shortcut     |
| ------------------- | -------- | ------------ |
| Buffer picker       | `bb`     | `<leader>bb` |
| Delete buffer       | `bd`     | `<leader>bd` |
| Close other buffers | `bo`     | `<leader>bo` |
| Close all buffers   | `bW`     | `<leader>bW` |

## Diagnostic

| Action              | WhichKey | Shortcut     |
| ------------------- | -------- | ------------ |
| Open float          | `d`      | `<leader>d`  |
| Set loclist         | `dl`     | `<leader>dl` |
| Next diagnostic     | `nd`     | `<leader>nd` |
| Previous diagnostic | `pd`     | `<leader>pd` |

`<leader>d` is the diagnostic group; delete-without-yank is `<leader>D` (see
Editing).

## File

| Action                 | WhichKey | Shortcut          |
| ---------------------- | -------- | ----------------- |
| Find files             |          | `<leader><space>` |
| Find files             |          | `<C-p>`           |
| File explorer (toggle) | `e`      | `<leader>e`       |
| Live grep              | `fw`     | `<leader>fw`      |
| Fuzzy grep             | `fz`     | `<leader>fz`      |
| Grep cursor word       | `ff`     | `<leader>ff`      |
| Format file            | `fm`     | `<leader>fm`      |

### File Explorer (`<leader>e` / `<A-e>`)

| Key             | Action         | Description                                                                                                 |
| --------------- | -------------- | ----------------------------------------------------------------------------------------------------------- |
| `h` / `<Left>`  | Focus parent   | Visual nav (no CWD change). File: collapse parent. Folder: collapse (if expanded) and move cursor to parent |
| `l` / `<Right>` | Toggle folder  | Expand if collapsed, collapse if expanded                                                                   |
| `j` / `<Down>`  | Move down      | Navigate list down                                                                                          |
| `k` / `<Up>`    | Move up        | Navigate list up                                                                                            |
| `<C-d>` / `]`   | Jump down 2    | Small jump (like section jump)                                                                              |
| `<C-u>` / `[`   | Jump up 2      | Small jump                                                                                                  |
| `}`             | Jump down 4    | Medium jump (like paragraph jump)                                                                           |
| `{`             | Jump up 4      | Medium jump                                                                                                 |
| `c`             | Copy           | Copy file(s) to target directory                                                                            |
| `p`             | Paste          | Paste files from clipboard                                                                                  |
| `m`             | Move           | Move file(s) with confirmation                                                                              |
| `d`             | Delete         | Trash file(s) with confirmation                                                                             |
| `D`             | Duplicate      | Duplicate file or directory with new name                                                                   |
| `y`             | Yank content   | Copy file text content to clipboard                                                                         |
| `Y`             | Yank path      | Copy full file path(s) to clipboard                                                                         |
| `r`             | Rename         | Rename file                                                                                                 |
| `a`             | Add file       | Create new file                                                                                             |
| `.`             | Focus          | Focus current file/dir in view                                                                              |
| `I`             | Toggle ignored | Show/hide gitignored files                                                                                  |
| `H`             | Toggle hidden  | Show/hide dotfiles                                                                                          |
| `/`             | Search field   | Focus the search input (`i` also works)                                                                     |

Explorer toggle: `<leader>e` opens/closes; `<A-e>` (Alt/Option+e) closes if open or focuses if cursor is elsewhere. `q` closes the explorer.

Search field: `/` jumps to it from either window (`i` works too). `<Esc>` inside
the search only unfocuses it — the query is cleared and focus returns to the
list; the explorer stays open. `<Esc>` in the list closes the explorer once the
query is empty.

## Git

| Action        | WhichKey | Shortcut     |
| ------------- | -------- | ------------ |
| LazyGit       | `gg`     | `<leader>gg` |
| Push          | `gp`     | `<leader>gp` |
| Status        | `gs`     | `<leader>gs` |
| Next hunk     |          | `]c`         |
| Previous hunk |          | `[c`         |

### Git Hunk

| Action          | WhichKey | Shortcut     |
| --------------- | -------- | ------------ |
| Stage hunk      | `hs`     | `<leader>hs` |
| Reset hunk      | `hr`     | `<leader>hr` |
| Stage buffer    | `hS`     | `<leader>hS` |
| Reset buffer    | `hR`     | `<leader>hR` |
| Unstage/reset   | `hu`     | `<leader>hu` |
| Preview hunk    | `hp`     | `<leader>hp` |
| Blame line      | `hb`     | `<leader>hb` |
| Diff (index)    | `hd`     | `<leader>hd` |
| Diff (commit)   | `hD`     | `<leader>hD` |
| Toggle blame    | `tb`     | `<leader>tb` |
| Preview deleted | `tD`     | `<leader>tD` |

## Go

| Action               | Shortcut     |
| -------------------- | ------------ |
| Run gotestsum (file) | `<leader>gt` |
| Run gotestsum (all)  | `<leader>gT` |

## LSP

| Action                  | WhichKey | Shortcut     |
| ----------------------- | -------- | ------------ |
| Code action             | `ca`     | `<leader>ca` |
| Rename                  | `rn`     | `<leader>rn` |
| Definition              |          | `gD`         |
| Declaration             |          | `gs`         |
| References              |          | `gr`         |
| References (picker)     |          | `grr`        |
| Implementation          |          | `gi`         |
| Implementation (picker) |          | `gri`        |
| Definition (picker)     |          | `grd`        |
| Declaration             |          | `grD`        |
| Hover                   |          | `K`          |
| Signature help          |          | `<C-k>`      |
| Document symbols        |          | `gO`         |
| Workspace symbols       |          | `gW`         |
| Type definition         |          | `grt`        |
| Format file             | `fm`     | `<leader>fm` |

## Marks

| Action           | WhichKey | Shortcut     |
| ---------------- | -------- | ------------ |
| Toggle file mark | `ma`     | `<leader>ma` |
| Clear marks      | `mc`     | `<leader>mc` |
| List marks       |          | `<C-l>`      |
| Next mark        |          | `<C-n>`      |
| Previous mark    | `mp`     | `<leader>mp` |

Inside the marks picker (`<C-l>`):

- `Enter` — jump to selected file
- `dd` — remove mark
- `Tab` — select mark for swap, then Tab on another mark to swap order

## Plugins

| Action                 | Shortcut     |
| ---------------------- | ------------ |
| Update plugins         | `<leader>pu` |
| Clear cache & restart  | `:CleanNvim` |
| Mason: manage packages | `<leader>tm` |
| Mason: TUI (tree view) | `<leader>tM` |

## Search

| Action                 | WhichKey | Shortcut     |
| ---------------------- | -------- | ------------ |
| swpui (search/replace) | `sr`     | `<leader>sr` |
| Live grep              | `fw`     | `<leader>fw` |
| Fuzzy grep             | `fz`     | `<leader>fz` |
| Grep cursor word       | `ff`     | `<leader>ff` |
| Clear search           | `sc`     | `<leader>sc` |
| Skip match (multicursor) | `ss`   | `<leader>ss` |
| Next result            |          | `n`          |
| Previous result        |          | `N`          |

## Tools

| Action           | WhichKey | Shortcut     |
| ---------------- | -------- | ------------ |
| Terminal         | `tt`     | `<leader>tt` |
| Terminal (cwd)   | `tT`     | `<leader>tT` |
| LazyGit          | `gg`     | `<leader>gg` |
| Resource Monitor | `tr`     | `<leader>tr` |

### Resource Monitor (`<leader>tr`)

Uses the first available of `mactop`, `btop`, `htop`; warns when none exist.

Requires installation:

- macOS: `brew install mactop` (Apple Silicon)
- Linux: `brew install btop` (cross-platform)

### Mason (`:MasonPkg` / `<leader>tm`)

| Action                   | Shortcut / Command              | Description                                                                                            |
| ------------------------ | ------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Mason: manage packages   | `<leader>tm` / `:MasonPkg`      | Browse & manage LSP/formatter/linter/DAP/runtime/compiler packages                                     |
| Mason: TUI (tree view)   | `<leader>tM`                    | Native Mason TUI with expand/collapse navigation                                                       |
| Mason: package category  | `:MasonPkg LSP` (etc.)          | Open picker filtered to a specific category (LSP, Formatter, Linter, DAP, Runtime, Compiler, or `all`) |
| Mason: install package   | `i` (in picker)                 | Install the selected package(s)                                                                        |
| Mason: uninstall package | `x` (in picker)                 | Uninstall the selected package(s)                                                                      |
| Mason: cycle category    | `<Tab>` / `<S-Tab>` (in picker) | Cycle through package categories                                                                       |

## LSP Toggles (`<leader>l`)

| Action                | Shortcut     | Description                                |
| --------------------- | ------------ | ------------------------------------------ |
| Toggle inlay hints    | `<leader>li` | Show/hide LSP inlay hints                  |
| Toggle diagnostics    | `<leader>ld` | Enable/disable diagnostics display         |
| Toggle format on save | `<leader>lf` | Enable/disable auto-format on save         |
| Toggle smooth scroll  | `<leader>ls` | Enable/disable smooth scroll animation     |
| LSP client info       | `<leader>lI` | Show attached LSP clients and their config |

## User Commands

| Command         | Description                                               |
| --------------- | --------------------------------------------------------- |
| `:Format`       | Format the current buffer with conform.nvim (range ignored) |
| `:FormatCode`   | Alias of `:Format` (same conform pipeline)                   |
| `:Update`       | Update all plugins (alias for `vim.pack.update()`)        |
| `:LspRestart`   | Restart all attached LSP clients                          |
| `:HealthCheck`  | Run health check (Neovim version, tools, LSP, pack-lock)  |
| `:ReloadConfig` | Reload Neovim config without restarting                   |

## Editing

| Action              | WhichKey | Shortcut    |
| ------------------- | -------- | ----------- |
| Delete without yank | `D`      | `<leader>D` |
| Join lines          |          | `J`         |
| Indent left         |          | `<`         |
| Indent right        |          | `>`         |
| Move line down      |          | `<A-j>`     |
| Move line up        |          | `<A-k>`     |
| Undo (with toast)   |          | `u`         |
| Redo (with toast)   |          | `<C-r>`     |

## Multicursor

Trigger eksplisit — tidak aktif di normal mode sampai dipanggil.

| Action           | Key              | Description                                             |
| ---------------- | ---------------- | ------------------------------------------------------- |
| Select word      | `mc`             | Select word under cursor, repeat to add next occurrence |
| Next match       | `<leader>n`      | Add cursor to next match of word/selection              |
| Prev match       | `<leader>N`      | Add cursor to previous match                            |
| Skip match       | `<leader>ss`     | Skip next match without adding cursor                   |
| Skip prev        | `<leader>M`      | Skip previous match                                     |
| Add cursor above | `<leader><up>`   | Add cursor on line above                                |
| Add cursor below | `<leader><down>` | Add cursor on line below                                |
| Click cursor     | `<C-leftmouse>`  | Add cursor at mouse click position                      |
| All matches      | `<leader>A`      | Add cursor to every match of word/selection in buffer   |
| Align cursors    | `<leader>a`      | Align all cursor columns                                |
| Restore          | `<leader>gv`     | Restore last cursor set                                 |

**Keymap layer** (hanya aktif saat multi-cursor):

| Action          | Key         |
| --------------- | ----------- |
| Previous cursor | `<left>`    |
| Next cursor     | `<right>`   |
| Delete cursor   | `<leader>x` |
| Clear cursors   | `<esc>`     |

## Window

`<C-S-...>` and `<C-A-...>` combinations are not transmitted by most
terminals, so window actions use the `<leader>w` group.

| Action           | WhichKey | Shortcut     |
| ---------------- | -------- | ------------ |
| Split vertical   | `wv`     | `<leader>wv` |
| Split vertical   |          | `<C-\>`     |
| Split horizontal | `ws`     | `<leader>ws` |
| Previous window  | `ww`     | `<leader>ww` |
| Close window     | `wq`     | `<leader>wq` |
| Equalize splits  | `w=`     | `<leader>w=` |
| Increase width   | `w+`     | `<leader>w+` |
| Decrease width   | `w-`     | `<leader>w-` |
| Increase height  | `w>`     | `<leader>w>` |
| Decrease height  | `w<`     | `<leader>w<` |

## Scrolling

Native Neovim behaviour, with one exception for `<S-Up>`/`<S-Down>`:

| Action          | Shortcut                                  |
| --------------- | ----------------------------------------- |
| One line        | `<C-e>` / `<C-y>`                         |
| Half page       | `<C-d>` / `<C-u>`, `<S-Down>` / `<S-Up>`, `}` / `{` |
| Page            | `<C-f>` / `<C-b>`                         |
| Mouse wheel     | `<ScrollWheelUp/Down>`                    |

`<S-Up>`/`<S-Down>` and `}`/`{` use the same builtin as `<C-u>`/`<C-d>`, so a
half page always means the same thing (normal mode only — insert mode,
visual-mode selection and operator-pending motions like `d}`/`v{` keep the
native behaviour).

The viewport never travels past the last buffer line (`lua/core_scroll.lua`,
loaded before snacks.nvim so it sees scroll events first):

- the topline is corrected before snacks.scroll animates, so nothing snaps back
  afterwards
- only the clamped scroll skips the animation; normal scrolling stays smooth
- `scrolloff = 0`, so the cursor is never dragged along by view scrolling and no
  empty space is reserved below the last line

`<C-b>` is remapped to the buffer picker in this config, so page up is
`<C-u>` ×2 or `<C-y>`.

Smooth scrolling comes from `snacks.scroll` (`lua/core_plugins.lua`):
45 ms per scrolled line, 240 ms cap, 16 ms/line once a key is held for 130 ms.
Set `vim.g.snacks_scroll = false` to disable it for the session.

## Markdown

| Action               | Shortcut     |
| -------------------- | ------------ |
| Toggle inline render | `<leader>mt` |
| Open link under cursor | `<C-CR>` or `<leader>ml` |

Link opening reads the URL straight from the buffer, so it works with the
renderer and conceal active: `[label](https://url "title")`, `<https://url>`
autolinks and bare URLs are all recognised (`:MarkdownOpenLink` does the same).
Ctrl+Enter needs a terminal that forwards it — Ghostty/kitty/wezterm do, and
Neovim enables the kitty keyboard protocol automatically; `<leader>ml` always
works.

The inline preview is rendered in normal, visual, command and terminal modes —
**not** in insert mode. While typing you get the raw markdown (`- item`,
`` `code` ``, `[text](url)`, ``` fences), and `conceallevel` drops to 0 outside
the rendered modes so nothing is concealed.

The preview keeps the sign column empty: `heading.sign = false` and
`code.sign = false` remove the heading glyph and the code-block language glyph
(bullets, checkbox icons, table borders and the code background are still
rendered as virtual text, not signs).

Headings carry no background band at any level: the plugin maps
`backgrounds[level]` to `RenderMarkdownH1Bg..H6Bg`, which link to `DiffText` /
`Visual` / `CursorColumn` in this theme, so H1, H5 and H6 used to be the only
ones with a background. `heading.backgrounds = {}` in `lua/plugin_markdown.lua`
disables it for all levels; the heading colours come from treesitter
(`@markup.heading.1..6`).

Links carry no icon prefix: the renderer's fallback glyph (󰌹) and its
per-site icons (`web` → 󰖟 for http, `github` → 󰊤, …) are disabled
(`link.enabled = false`), because documents that already draw their own glyph
next to the label ended up with two icons. Links stay recognisable from the soft
blue colour.

Inline code is rendered foreground-only (`RenderMarkdownCodeInline` carries no
background) and uses the theme `@markup.raw` colour — soft purple `#9976cb` —
while links use `@markup.link`, a soft blue `#498bc9`, so the two never look
alike even with the backticks concealed. Both are desaturated towards the
background (Soft* colours in `core_theme.lua`) and still sit at ~4.8:1 contrast.
Code blocks keep their usual background band.

## Gutter

Kept minimal: git hunks (`▎` bars, colour = add/change/delete), errors (`󰅚`) and
warnings (`󰀪`). Info/hint diagnostics, markdown preview signs and the `~` end-of-
buffer marker do not write to it (`fillchars eob` is a space, `signcolumn` stays
reserved so text never shifts).

## Insert Mode

| Action      | Shortcut |
| ----------- | -------- |
| Delete word | `<C-w>`  |
| Delete line | `<C-u>`  |
