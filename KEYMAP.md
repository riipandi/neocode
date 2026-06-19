# Keymaps

## General

| Action                 | WhichKey | Shortcut     |
|------------------------|----------|--------------|
| Quit all               | `q`      | `<leader>q`  |
| Quit all               | `qq`     | `<leader>qq` |
| Quit all               |          | `<C-q>` / `<A-q>` |
| Close buffer or split  |          | `<C-x>`      |
| Close all buffers      |          | `<C-S-w>`    |
| Command palette        | `;`      | `<leader>;`  |
| Edit config            | `,`      | `<leader>,`  |

> **Note:** `<C-x>` keeps the file explorer open and shows a blank buffer when the last editor buffer is closed, instead of letting the explorer expand to full width.
## Escape Key

| Action                | Shortcut | Description                               |
|-----------------------|----------|-------------------------------------------|
| Close floating window | `<Esc>`  | Closes terminal, lazygit, picker, etc.    |
| Clear search          | `<Esc>`  | Clears search highlights in normal buffer |

## Buffer

| Action              | WhichKey | Shortcut     |
|---------------------|----------|--------------|
| Buffer picker       | `bb`     | `<leader>bb` |
| Delete buffer       | `bd`     | `<leader>bd` |
| Close other buffers | `bo`     | `<leader>bo` |

## Diagnostic

| Action               | WhichKey | Shortcut     |
|----------------------|----------|--------------|
| Open float           | `d`      | `<leader>d`  |
| Set loclist          | `dl`     | `<leader>dl` |
| Next diagnostic      | `nd`     | `<leader>nd` |
| Previous diagnostic  | `pd`     | `<leader>pd` |

## File

| Action            | WhichKey | Shortcut          |
|-------------------|----------|-------------------|
| Find files        |          | `<leader><space>` |
| Find files        |          | `<C-p>`           |
| File explorer (toggle) | `e`      | `<leader>e`       |
| Live grep         | `fw`     | `<leader>fw`      |
| Fuzzy grep        | `fz`     | `<leader>fz`      |
| Grep cursor word  | `fc`     | `<leader>fc`      |
| Format file       | `fm`     | `<leader>fm`      |

### File Explorer (`<leader>e` / `<A-e>`)

| Key | Action | Description |
|-----|--------|-------------|
| `h` / `<Left>` | Focus parent | Visual nav (no CWD change). File: collapse parent. Folder: collapse (if expanded) and move cursor to parent |
| `l` / `<Right>` | Toggle folder | Expand if collapsed, collapse if expanded |
| `j` / `<Down>` | Move down | Navigate list down |
| `k` / `<Up>` | Move up | Navigate list up |
| `<C-d>` / `]` | Jump down 2 | Small jump (like section jump) |
| `<C-u>` / `[` | Jump up 2 | Small jump |
| `}` | Jump down 4 | Medium jump (like paragraph jump) |
| `{` | Jump up 4 | Medium jump |
| `c` | Copy | Copy file(s) to target directory |
| `p` | Paste | Paste files from clipboard |
| `m` | Move | Move file(s) with confirmation |
| `d` | Delete | Trash file(s) with confirmation |
| `D` | Duplicate | Duplicate file or directory with new name |
| `y` | Yank content | Copy file text content to clipboard |
| `Y` | Yank path | Copy full file path(s) to clipboard |
| `r` | Rename | Rename file |
| `a` | Add file | Create new file |
| `.` | Focus | Focus current file/dir in view |
| `I` | Toggle ignored | Show/hide gitignored files |
| `H` | Toggle hidden | Show/hide dotfiles |

Explorer toggle: `<leader>e` opens/closes; `<A-e>` (Alt/Option+e) closes if open or focuses if cursor is elsewhere.
## Git

| Action               | WhichKey | Shortcut     |
|----------------------|----------|--------------|
| LazyGit              | `gg`     | `<leader>gg` |
| Push                 | `gp`     | `<leader>gp` |
| Status               | `gs`     | `<leader>gs` |
| Next hunk            |          | `]c`         |
| Previous hunk        |          | `[c`         |

### Git Hunk

| Action            | WhichKey | Shortcut     |
|-------------------|----------|--------------|
| Stage hunk        | `hs`     | `<leader>hs` |
| Reset hunk        | `hr`     | `<leader>hr` |
| Stage buffer      | `hS`     | `<leader>hS` |
| Reset buffer      | `hR`     | `<leader>hR` |
| Undo stage hunk   | `hu`     | `<leader>hu` |
| Preview hunk      | `hp`     | `<leader>hp` |
| Blame line        | `hb`     | `<leader>hb` |
| Diff (index)      | `hd`     | `<leader>hd` |
| Diff (commit)     | `hD`     | `<leader>hD` |
| Toggle blame      | `tb`     | `<leader>tb` |
| Toggle deleted    | `tD`     | `<leader>tD` |

## Go

| Action               | Shortcut     |
|----------------------|--------------|
| Run gotestsum (file) | `<leader>gt` |
| Run gotestsum (all)  | `<leader>gT` |

## LSP

| Action                   | WhichKey | Shortcut          |
|--------------------------|----------|-------------------|
| Code action              | `ca`     | `<leader>ca`      |
| Rename                   | `rn`     | `<leader>rn`      |
| Definition               |          | `gD`              |
| Declaration              |          | `gs`              |
| References               |          | `gr`              |
| References (picker)      |          | `grr`             |
| Implementation           |          | `gi`              |
| Implementation (picker)  |          | `gri`             |
| Definition (picker)      |          | `grd`             |
| Declaration              |          | `grD`             |
| Hover                    |          | `K`               |
| Signature help           |          | `<C-k>`           |
| Document symbols         |          | `gO`              |
| Workspace symbols        |          | `gW`              |
| Type definition          |          | `grt`             |
| Format file              | `fm`     | `<leader>fm`      |

## Marks

| Action              | WhichKey | Shortcut   |
|---------------------|----------|------------|
| Toggle file mark    | `ma`     | `<leader>ma` |
| Clear marks         | `mc`     | `<leader>mc` |
| List marks          |          | `<C-l>`    |
| Next mark           |          | `<C-n>`    |
| Previous mark       |          | `<C-S-m>`  |

Inside the marks picker (`<C-l>`):
- `Enter` — jump to selected file
- `dd` — remove mark
- `Tab` — select mark for swap, then Tab on another mark to swap order

## Plugins

| Action                         | Shortcut            |
|--------------------------------|---------------------|
| Update plugins                 | `<leader>pu`        |
| Clear cache & restart          | `:CleanNvim`        |
| Mason: manage packages         | `<leader>tm`        |
| Mason: TUI (tree view)         | `<leader>tM`        |

## Search

| Action               | WhichKey | Shortcut     |
|----------------------|----------|--------------|
| Serpl (search/replace)| `sr`    | `<leader>sr` |
| Global search (Serpl)|          | `<C-S-f>`    |
| Live grep            | `fw`     | `<leader>fw` |
| Fuzzy grep           | `fz`     | `<leader>fz` |
| Grep cursor word     | `fc`     | `<leader>fc` |
| Clear search         | `c`      | `<leader>c`  |
| Next result          |          | `n`          |
| Previous result      |          | `N`          |

## Tools

| Action            | WhichKey | Shortcut     |
|-------------------|----------|--------------|
| Terminal          | `tt`     | `<leader>tt` |
| LazyGit           | `gg`     | `<leader>gg` |
| Resource Monitor  | `tr`     | `<leader>tr` |

### Resource Monitor (`<leader>tr`)

Requires installation:
- macOS: `brew install mactop` (Apple Silicon)
- Linux: `brew install btop` (cross-platform)

### Mason (`:MasonPkg` / `<leader>tm`)

| Action | Shortcut / Command | Description |
|--------|---------------------|-------------|
| Mason: manage packages | `<leader>tm` / `:MasonPkg` | Browse & manage LSP/formatter/linter/DAP/runtime/compiler packages |
| Mason: TUI (tree view) | `<leader>tM` | Native Mason TUI with expand/collapse navigation |
| Mason: package category | `:MasonPkg LSP` (etc.) | Open picker filtered to a specific category (LSP, Formatter, Linter, DAP, Runtime, Compiler, or `all`) |
| Mason: install package | `i` (in picker) | Install the selected package(s) |
| Mason: uninstall package | `x` (in picker) | Uninstall the selected package(s) |
| Mason: cycle category | `<Tab>` / `<S-Tab>` (in picker) | Cycle through package categories |

## Editing

| Action              | WhichKey | Shortcut    |
|---------------------|----------|-------------|
| Delete without yank | `d`      | `<leader>d` |
| Join lines          |          | `J`         |
| Indent left         |          | `<`         |
| Indent right        |          | `>`         |
| Move line down      |          | `<A-j>`     |
| Move line up        |          | `<A-k>`     |
| Undo (with toast)   |          | `u`         |
| Redo (with toast)   |          | `<C-r>`     |

## Window

| Action           | WhichKey | Shortcut    |
|------------------|----------|-------------|
| Split vertical   |          | `<C-\>`     |
| Split horizontal |          | `<C-S-\>`   |
| Previous window  |          | `<C-A-[>`   |
| Next window      |          | `<C-A-]>`   |
| Increase width   |          | `<C-A-=>`   |
| Decrease width   |          | `<C-A-->`   |
| Increase height  |          | `<C-S-=>`   |
| Decrease height  |          | `<C-S-->`   |

## Insert Mode

| Action      | Shortcut |
|-------------|----------|
| Delete word | `<C-w>`  |
| Delete line | `<C-u>`  |
