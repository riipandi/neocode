# Keymaps

Leader: `<Space>`. Every mapping below is global unless the section says
otherwise (LSP, markdown link and explorer keys are buffer-local).

Neovim builtins stay available: `zM`/`zR` (close/open all folds), `za`, `gx`
(open path or URL), `]`/`[` prefixes (diagnostics, quickfix, buffers), `gr*`
(`grn`, `gra`, `grr`, `gri`, `grt`).

## Scrolling

| Action        | Keys                                              |
| ------------- | ------------------------------------------------- |
| One line      | `<C-e>` / `<C-y>`                                 |
| Half page     | `<C-d>` / `<C-u>`, `<S-Down>` / `<S-Up>`, `}` / `{` |
| Page down     | `<C-f>`                                           |
| Mouse wheel   | `<ScrollWheelUp>` / `<ScrollWheelDown>`           |

`<S-Down>`/`<S-Up>` and `}`/`{` run the same builtin as `<C-d>`/`<C-u>` so a
half page means one thing everywhere (`lua/core_keymaps/scroll.lua`, normal mode
only). Paragraph motion is still available in operator-pending and visual mode
(`d}`, `v{`).

`<C-b>` opens the buffer list here, so it is not page up. Scrolling is native:
the viewport can pass the last line, and `scrolloff = 0` means the cursor is
never dragged by view scrolling.

Smooth scrolling comes from `snacks.scroll` (`lua/core_plugins.lua`): 45 ms per
scrolled line, 240 ms cap, 16 ms/line once a key is held for 130 ms.
`vim.g.snacks_scroll = false` disables it for the session; `<leader>ls` toggles
the unrelated `smoothscroll` option.

## Folds

`foldmethod=expr` with the treesitter foldexpr, set globally in `init.lua`. A
fold is a syntax block: function, object literal, markdown section.

| Action                     | Keys          |
| -------------------------- | ------------- |
| Toggle fold around cursor  | `<S-CR>`      |
| Same, when the terminal eats Shift+Enter | `<M-CR>` |
| Toggle every fold          | `<M-S-CR>`    |
| Close all / open all       | `zM` / `zR`   |

`<S-CR>` and `<M-CR>` are a smart toggle (`lua/core_keymaps/folds.lua`) because
plain `za` aborts with E490 on rows that hold no fold:

1. cursor inside a closed fold → open it
2. cursor on a foldable row → close the innermost fold around it
3. cursor on a top-level row → fold the nearest block below (else above), cursor
   stays where it was
4. nothing foldable → an info message instead of an error

`<M-S-CR>` closes all folds when the window `foldlevel` is open and opens all
when anything is closed. Ctrl+Shift+Enter is avoided; the terminal uses it.

Shift+Enter, Option+Enter and Option+Shift+Enter only arrive as distinct keys
when the terminal forwards them (kitty keyboard protocol — Ghostty, kitty,
wezterm). Run `:KeyProbe` and press the key to see what Neovim receives.

## Buffers

| Action              | Keys          |
| ------------------- | ------------- |
| Save current file (normal and insert mode, stays in the current mode) | `<C-s>` |
| Close buffer (smart, asks about unsaved changes) | `<C-x>` |
| Buffer picker       | `<C-b>`, `<leader>bb` |
| Delete buffer       | `<leader>bd`  |
| Close other buffers | `<leader>bo`  |
| Close all buffers   | `<leader>bW`  |

## Windows

| Action            | Keys               |
| ----------------- | ------------------ |
| Split vertical    | `<C-\>`, `<leader>wv` |
| Split horizontal  | `<leader>ws`       |
| Previous window   | `<leader>ww`       |
| Close window      | `<leader>wq`       |
| Equalize splits   | `<leader>w=`       |
| Resize width      | `<leader>w+` / `<leader>w-` |
| Resize height     | `<leader>w>` / `<leader>w<` |

`<C-S-...>` and `<C-A-...>` combinations are not transmitted by most terminals,
which is why window actions live in the `<leader>w` group.

## Search

| Action                       | Keys                          |
| ---------------------------- | ----------------------------- |
| Find files                   | `<C-p>`, `<leader><Space>`    |
| Live grep                    | `<leader>fw`                  |
| Fuzzy grep                   | `<leader>fz`                  |
| Grep word under cursor       | `<leader>ff`                  |
| Search & replace (swpui)     | `<leader>sr`                  |
| Clear search highlights      | `<leader>sc`                  |
| Next / previous match        | `n` / `N` (centered)          |

Files and grep use fff.nvim; swpui runs in a floating terminal (`swp`).
`:search` runs natively, so `/pat/e` offsets work and a miss shows the E486
message through noice.

## Editing

| Action                    | Keys                     |
| ------------------------- | ------------------------ |
| Delete without yanking    | `<leader>D` (n, x)       |
| Join lines, keep cursor   | `J`                      |
| Move line / selection     | `<A-j>` / `<A-k>`        |
| Indent and reselect       | `<` (visual)             |
| Undo / redo with toast    | `u` / `<C-r>`            |
| Copy file path            | `<leader>pa`             |
| Change cwd to file's dir  | `<leader>cd`             |

`<leader>d` is not used for text: it is the LSP diagnostic float (buffer-local,
see LSP).

## Command palette

| Action                    | Keys        |
| ------------------------- | ----------- |
| Insert a command (snacks input) | `<leader>;` |
| Search all commands       | `<leader>:` |
| Same, terminals that forward Shift | `<C-S-p>` |
| Go to line or `line:col`  | `<C-g>`     |

## Tools

| Action                     | Keys           |
| -------------------------- | -------------- |
| Terminal (toggle)          | `<leader>tt`   |
| Terminal in cwd            | `<leader>tT`   |
| Resource monitor           | `<leader>tr`   |
| Mason package picker       | `<leader>tm`   |
| Mason TUI                  | `<leader>tM`   |
| Scratch buffer             | `<leader>.`    |
| Select scratch buffer      | `<leader>S`    |
| Update plugins             | `<leader>pu`   |
| Edit this config           | `<leader>,`    |

`<leader>tr` runs the first available of `mactop`, `btop`, `htop` and warns when
none is installed.

## Quit and dialogs

| Action        | Keys                        |
| ------------- | --------------------------- |
| Quit all      | `<leader>q`, `<leader>qq`, `<C-q>`, `<A-q>` |
| Cancel a dialog | `<Esc>`                   |

Dialogs (quit, unsaved buffer, Mason actions) open through `vim.ui.select` with
the list focused, so you stay in normal mode: `j`/`k` to move, `<CR>` to choose,
`<Esc>` to cancel, `/` to type in the search field. A dialog opened from insert
mode keeps the input focused instead.

## File explorer (`<leader>e`)

`<leader>e` toggles; `<A-e>` closes it when open or focuses it when the cursor is
elsewhere.

| Key            | Action                                                        |
| -------------- | ------------------------------------------------------------- |
| `h` / `<Left>` | File: jump to the parent folder. Expanded folder: collapse it and stay. Collapsed folder: jump to the parent |
| `l` / `<Right>`| Expand / collapse the folder                                  |
| `j` / `k`      | Move down / up                                                |
| `<C-d>` / `]`  | Move two rows down                                            |
| `<C-u>` / `[`  | Move two rows up                                              |
| `}` / `{`      | Move four rows down / up                                      |
| `c` / `p` / `m`/ `d` / `D` | Copy, paste, move, delete, duplicate               |
| `y` / `Y`      | Yank file content / full path                                 |
| `r` / `a`      | Rename / add file                                             |
| `.`            | Focus the current file in the view                            |
| `I` / `H`      | Toggle ignored / hidden files                                 |
| `/`            | Focus the search field                                        |
| `q`            | Close the explorer                                            |
| `<Esc>`        | Search field: clear the query and return to the list (never closes). List: close when the query is empty |

## Pickers

Snacks picker windows share these keys:

| Key          | Action                                    |
| ------------ | ----------------------------------------- |
| `<Esc>`      | Close the picker                          |
| `<C-q>` / `<A-q>` | Close the picker, then ask to quit   |
| `e`          | Focus the editor window                   |
| `<C-d>`/`<C-u>` | Scroll the list (explorer remaps these to row jumps) |

## Git

| Action              | Keys                          |
| ------------------- | ----------------------------- |
| LazyGit             | `<leader>gg`                  |
| Push                | `<leader>gp` (terminal `git push`) |
| Status picker       | `<leader>gs`                  |
| Next / previous hunk| `]c` / `[c` (buffer-local)    |
| Stage / reset hunk  | `<leader>hs` / `<leader>hr`   |
| Stage buffer        | `<leader>hS`                  |
| Reset buffer        | `<leader>hR`                  |
| Unstage/reset hunk  | `<leader>hu`                  |
| Preview hunk        | `<leader>hp`                  |
| Blame line          | `<leader>hb`                  |
| Diff against index  | `<leader>hd`                  |
| Diff against HEAD   | `<leader>hD`                  |
| Toggle line blame   | `<leader>tb`                  |
| Preview deleted lines | `<leader>tD`                |
| gotestsum (file / all) | `<leader>gt` / `<leader>gT` |

Hunk keys are buffer-local and only exist when gitsigns attaches.

## LSP (buffer-local, set on attach)

| Action                     | Keys            |
| -------------------------- | --------------- |
| Definition / declaration   | `gD` / `gs`     |
| References / implementation| `gr` / `gi`     |
| Definition picker          | `grd`           |
| References picker          | `grr`           |
| Implementation picker      | `gri`           |
| Declaration                | `grD`           |
| Rename                     | `<leader>rn`, `grn` |
| Code action                | `<leader>ca`, `gra` (n, x) |
| Hover / signature help     | `K` / `<C-k>`   |
| Document / workspace symbols | `gO` / `gW`   |
| Type definition picker     | `grt`           |
| Inlay hints toggle         | `<leader>th`    |
| Toggle inlay hints         | `<leader>li` (global; `<leader>th` above is buffer-local) |
| Diagnostics float          | `<leader>d`     |
| Next / previous diagnostic | `<leader>nd` / `<leader>pd` |
| Diagnostics to loclist     | `<leader>dl`    |
| Toggle diagnostics         | `<leader>ld`    |
| Toggle format on save      | `<leader>lf`    |
| LSP client info            | `<leader>lI`    |

`<leader>lf` sets `vim.g.auto_format`; actual format-on-save honours
`vim.b.disable_autoformat` (conform). See `:LspInfo`, `:LspRestart`,
`:ConformInfo`.

## Marks (miniharp)

| Action              | Keys        |
| ------------------- | ----------- |
| Toggle mark         | `<leader>ma` |
| Clear marks         | `<leader>mc` |
| Next / previous mark| `<C-n>` / `<leader>mp` |
| List marks          | `<C-l>`     |

Inside the marks picker: `<CR>` jumps, `dd` removes, `<Tab>` picks the first mark
of a swap and `<Tab>` on another completes it.

## AI (Mistral Codestral)

| Action                        | Keys          |
| ----------------------------- | ------------- |
| Manual completion             | `<leader>ic`  |
| Toggle completions            | `<leader>it`  |
| Ghost preview on / off        | `<leader>iv` / `<leader>ix` |
| Auth manager                  | `<leader>iA`  |
| Health report                 | `<leader>ih`  |
| Commit message from `git diff`| `<leader>ig`  |
| Explain selected completion   | `<leader>ie` (insert and normal) |

Ghost text controls in insert mode: `<M-l>` accept, `<C-Right>` accept word,
`<C-Down>` accept line, `<M-]>` / `<M-[>` cycle, `<C-c>` clear (the key itself
still works as usual).

Set `CODESTRAL_API_KEY` in the environment; `MISTRAL_API_KEY` is the fallback.

## Markdown

| Action               | Keys                        |
| -------------------- | --------------------------- |
| Toggle inline render | `<leader>mt`                |
| Open link under cursor | `<C-CR>` (buffer-local) or `<leader>ml` |
| Same, from anywhere  | `:MarkdownOpenLink`         |

The preview only renders outside insert mode. Code blocks keep their background
and border; headings have no background and no sign; inline code is soft purple
`#9976cb` with no background, links are soft blue `#498bc9` with no icon prefix;
bullets are `◉ ○ ◆ ◇`. Links are read from the buffer, so conceal and the
renderer do not matter.

## Gutter

Git hunks (`▎` bars, colour = add/change/delete), errors (`󰅚`) and warnings
(`󰀪`). Info/hint diagnostics, markdown preview signs and the `~` end-of-buffer
marker do not write to it. `signcolumn` stays reserved so text never shifts.

## Multicursor

| Action               | Keys                            |
| -------------------- | ------------------------------- |
| Select word          | `mc` (repeat for the next match)|
| Add cursor           | `<leader>n` / `<leader>N`       |
| Skip match           | `<leader>ss` / `<leader>M`      |
| Cursor above / below | `<leader><Up>` / `<leader><Down>`(n, x) |
| All matches          | `<leader>A`                     |
| Align cursors        | `<leader>a`                     |
| Restore cursor set   | `<leader>gv`                    |
| Add cursor with mouse| `<C-LeftMouse>` (and drag/release) |

While multiple cursors exist: `<Left>`/`<Right>` move between cursors,
`<leader>x` deletes the main cursor, `<Esc>` enables or clears them.

## Insert mode

| Keys                | Action                                            |
| ------------------- | ------------------------------------------------- |
| `<C-S>`             | Signature help                                    |
| `<Tab>` / `<S-Tab>` | Jump through snippet placeholders when one is active |
| `<CR>`              | Accept completion, otherwise new line (autopairs) |

Completion is blink.cmp; `completeopt=menuone,noinsert,noselect,preview` and the
menu does not preselect an entry.

## Ctrl+Shift keys

Ghostty and other kitty-protocol terminals deliver Ctrl+Shift+letter as its own
key. Without a mapping Neovim falls back to the unmodified key, which is how
Ctrl+Shift+G used to print `<C-g>` file info and split the layout.

| Keys          | Action                                    |
| ------------- | ----------------------------------------- |
| `<C-S-g>`     | LazyGit                                   |
| `<C-S-f>`     | Search & replace (swpui)                  |
| `<C-S-s>`     | Terminal (toggle)                         |
| `<C-S-m>`     | Previous mark                             |
| `<C-S-p>`     | Command palette                           |
| `<C-S-w>`     | Swallowed (`<Nop>`) — it would otherwise start `<C-w>` |

## User commands

| Command               | Purpose                                             |
| --------------------- | --------------------------------------------------- |
| `:Format`             | Format the buffer with conform                      |
| `:FormatCode`         | Same pipeline (kept for muscle memory)              |
| `:Update`             | `vim.pack.update()`                                 |
| `:LspRestart`         | Restart every attached client                       |
| `:LspInfo`            | List clients attached to the buffer                 |
| `:ReloadConfig`       | Drop config modules and re-source `init.lua`        |
| `:CleanNvim`          | Delete `nvim-pack-lock.json` and the cache dir      |
| `:HealthCheck`        | Neovim version, tools, LSP, pack-lock               |
| `:MasonPkg [category]`| Mason picker (`LSP`, `Formatter`, `Linter`, `DAP`, `Runtime`, `Compiler`, `All`) |
| `:KeyProbe`           | Show the notation Neovim receives for the next key  |
| `:MarkdownOpenLink`   | Open the link under the cursor                      |
