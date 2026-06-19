# Keymaps

## General

| Action                 | WhichKey | Shortcut     |
|------------------------|----------|--------------|
| Quit all               | `q`      | `<leader>q`  |
| Quit all               | `qq`     | `<leader>qq` |
| Quit all               |          | `<C-q>`      |
| Close buffer or split  |          | `<C-x>`      |
| Close all buffers      |          | `<C-S-w>`    |
| Command palette        | `;`      | `<leader>;`  |
| Edit config            | `,`      | `<leader>,`  |

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
| File explorer     | `e`      | `<leader>e`       |
| Live grep         | `fw`     | `<leader>fw`      |
| Fuzzy grep        | `fz`     | `<leader>fz`      |
| Grep cursor word  | `fc`     | `<leader>fc`      |
| Format file       | `fm`     | `<leader>fm`      |

### File Explorer (`<leader>e`)

| Key | Action | Description |
|-----|--------|-------------|
| `h` / `<Left>` | Collapse / up | Close folder or go to parent |
| `l` / `<Right>` | Expand | Open folder or confirm file |
| `j` / `<Down>` | Move down | Navigate list down |
| `k` / `<Up>` | Move up | Navigate list up |
| `<S-Down>` | Scroll down | Move down 3 lines |
| `<S-Up>` | Scroll up | Move up 3 lines |
| `c` | Copy | Copy file(s) to target directory |
| `p` | Paste | Paste files from clipboard |
| `m` | Move | Move file(s) with confirmation |
| `d` | Delete | Trash file(s) with confirmation |
| `D` | Duplicate | Duplicate file with new name |
| `y` | Yank path | Copy full file path(s) to clipboard |
| `r` | Rename | Rename file |
| `a` | Add file | Create new file |
| `.` | Focus | Focus current file/dir in view |
| `I` | Toggle ignored | Show/hide gitignored files |
| `H` | Toggle hidden | Show/hide dotfiles |

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
