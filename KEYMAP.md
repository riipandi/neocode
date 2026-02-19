# Keymaps

## General

| Action                | WhichKey | Shortcut     |
|-----------------------|----------|--------------|
| Quit all              | `q`      | `<leader>q`  |
| Quit all              | `qq`     | `<leader>qq` |
| Close buffer          | `b`      | `<C-x>`      |
| Close all buffers     |          | `<C-S-w>`    |
| Clear search          | `c`      | `<leader>c`  |
| Change directory      | `ad`     | `<leader>ad` |
| Edit neovim config    | `f`      | `<leader>,`  |
| Toggle scratch buffer | `f`      | `<leader>.`  |

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

## Tools

| Action           | WhichKey  | Shortcut          |
|------------------|-----------|-------------------|
| Find files       | `<space>` | `<leader><space>` |
| File explorer    | `e`       | `<leader>e`       |
| Terminal         | `tt`      | `<leader>tt`      |
| LazyGit          | `tg`      | `<leader>tg`      |
| Search & Replace | `tf`      | `<leader>tf`      |
| Resource Monitor | `tr`      | `<leader>tr`      |
| Command palette  |           | `<C-S-p>`         |

### Resource Monitor (`<leader>tr`)

Requires installation:
- macOS: `brew install mactop` (Apple Silicon)
- Linux: `brew install btop` (cross-platform)

## Search

| Action           | WhichKey  | Shortcut          |
|------------------|-----------|-------------------|
| Find files       | `<space>` | `<leader><space>` |
| Serpl            | `sr`      | `<leader>sr`      |
| Serpl            | `tf`      | `<leader>tf`      |
| Global search    |           | `<C-S-f>`         |
| Next result      | `s`       | `<leader>n`       |
| Previous result  | `s`       | `<leader>N`       |
| Clear highlights | `s/c`     | `<leader>c`       |

## Git

| Action        | WhichKey | Shortcut     |
|---------------|----------|--------------|
| Git push      | `gp`     | `<leader>gp` |
| Next hunk     |          | `]c`         |
| Previous hunk |          | `[c`         |
| Stage hunk    | `hs`     | `<leader>hs` |
| Reset hunk    | `hr`     | `<leader>hr` |
| Stage buffer  | `hS`     | `<leader>hS` |
| Reset buffer  | `hR`     | `<leader>hR` |
| Preview hunk  | `hp`     | `<leader>hp` |
| Blame line    | `hb`     | `<leader>hb` |
| Diff this     | `hd`     | `<leader>hd` |

## LSP / Code

| Action              | WhichKey | Shortcut     |
|---------------------|----------|--------------|
| Goto definition     | `g`      | `gD`         |
| Goto declaration    | `g`      | `gs`         |
| Goto references     | `g`      | `gr`         |
| Goto implementation | `g`      | `gi`         |
| Hover               |          | `K`          |
| Signature help      |          | `<C-k>`      |
| Code action         | `la`     | `<leader>la` |
| Rename              | `lr`     | `<leader>lr` |
| Next diagnostic     |          | `<leader>nd` |
| Previous diagnostic |          | `<leader>pd` |
| Format file         |          | `<leader>fm` |

## Go Tools

| Action               | Shortcut     |
|----------------------|--------------|
| Run gotestsum (file) | `<leader>gt` |
| Run gotestsum (all)  | `<leader>gT` |

## OpenCode

| Action              | WhichKey | Shortcut     |
|---------------------|----------|--------------|
| Toggle panel        | `o`      | `<leader>oo` |
| Focus panel         | `of`     | `<leader>of` |
| Ask about this      | `oa`     | `<leader>oa` |
| Select prompt       | `os`     | `<leader>os` |
| Command             | `oc`     | `<leader>oc` |
| New session         | `on`     | `<leader>on` |
| Interrupt           | `oi`     | `<leader>oi` |
| Exit                | `ox`     | `<leader>ox` |
| Cycle agent         | `oA`     | `<leader>oA` |
| Add range to prompt |          | `go`         |
| Add line to prompt  |          | `goo`        |

## Window

| Action           | WhichKey | Shortcut  |
|------------------|----------|-----------|
| Split vertical   |          | `<C-\>`   |
| Split horizontal |          | `<C-S-\>` |
| Previous window  |          | `<C-A-[>` |
| Next window      |          | `<C-A-]>` |
| Increase width   |          | `<C-A-=>` |
| Decrease width   |          | `<C-A-->` |
| Increase height  |          | `<C-S-=>` |
| Decrease height  |          | `<C-S-->` |

## Scrolling

| Action      | WhichKey | Shortcut   |
|-------------|----------|------------|
| Scroll up   |          | `<S-Up>`   |
| Scroll down |          | `<S-Down>` |

## Editing

| Action              | WhichKey | Shortcut    |
|---------------------|----------|-------------|
| Delete without yank | `d`      | `<leader>d` |
| Join lines          |          | `J`         |
| Indent left         |          | `<`         |
| Indent right        |          | `>`         |
| Move line down      |          | `<A-j>`     |
| Move line up        |          | `<A-k>`     |

## Insert Mode

| Action      | Shortcut |
|-------------|----------|
| Delete word | `<C-w>`  |
| Delete line | `<C-u>`  |
