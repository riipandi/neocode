--[[

This is a personal Neovim configuration for Aris Ripandi (@riipandi).

  This configuration based on Kickstart.nvim. Kickstart.nvim is a starting point
  for your own configuration. The goal is that you can read every line of code,
  top-to-bottom, understand what your configuration is doing, and modify it to
  suit your needs.

Last updated: 2025-10-12 (nvim 0.11+)

--]]

-- theme & transparency (loaded in core_theme.lua)
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })

-- Basic settings
vim.opt.number = true                           -- Line numbers
vim.opt.relativenumber = false                  -- Relative line numbers
vim.opt.cursorline = true                       -- Highlight current line
vim.opt.wrap = false                            -- Don't wrap lines
vim.opt.scrolloff = 10                          -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 4                       -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2                             -- Tab width
vim.opt.shiftwidth = 2                          -- Indent width
vim.opt.softtabstop = 2                         -- Soft tab stop
vim.opt.expandtab = true                        -- Use spaces instead of tabs
vim.opt.smartindent = true                      -- Smart auto-indenting
vim.opt.autoindent = true                       -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true                       -- Case insensitive search
vim.opt.smartcase = true                        -- Case sensitive if uppercase in search
vim.opt.hlsearch = false                        -- Don't highlight search results
vim.opt.incsearch = true                        -- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true                    -- Enable 24-bit colors
vim.opt.signcolumn = "yes:1"                    -- Always show sign column
vim.opt.colorcolumn = "0"                       -- Show column ruler (n characters)

-- Completion menu settings
vim.opt.wildmenu = true                         -- Enable wildmenu for command completion
vim.opt.wildmode = "longest:full,full"          -- Complete longest common match, then list all
vim.opt.wildoptions = "pum"                     -- Use popup menu for completions
vim.opt.pumheight = 15                          -- Max items in popup menu
vim.opt.pumblend = 10                           -- Transparency for popup menu
vim.opt.completeopt = "menuone,noinsert,noselect,preview"  -- Completion options
vim.opt.showmatch = true                        -- Highlight matching brackets
vim.opt.matchtime = 2                           -- How long to show matching bracket
vim.opt.cmdheight = 0                           -- Command line height (noice handles UI)
vim.opt.showmode = false                        -- Don't show the mode, since it's already in the status line
vim.opt.winblend = 0                            -- Floating window transparency
vim.opt.conceallevel = 0                        -- Don't hide markup
vim.opt.concealcursor = ""                      -- Don't hide cursor line markup
vim.opt.lazyredraw = false                      -- Don't redraw during macros
vim.opt.synmaxcol = 300                         -- Syntax highlighting limit
vim.opt.fillchars:append({ eob = " " })         -- Hide tilde character (~) on empty lines
vim.opt.winborder = "rounded"                   -- Set window border style to rounded
vim.g.border_style = "rounded"                  -- Set global border style for floating windows
vim.g.markdown_recommended_style = 0            -- Fix markdown indentation settings

-- File handling
vim.opt.backup = false                             -- Don't create backup files
vim.opt.writebackup = false                        -- Don't create backup before writing
vim.opt.swapfile = false                           -- Don't create swap files
vim.opt.undofile = true                            -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")  -- Undo directory
vim.opt.updatetime = 300                           -- Faster completion
vim.opt.timeoutlen = 500                           -- Key timeout duration
vim.opt.ttimeoutlen = 0                            -- Key code timeout
vim.opt.autoread = true                            -- Auto reload files changed outside vim
vim.opt.autowrite = false                          -- Don't auto save
vim.opt.confirm = true                             -- Raise dialog to save changes

-- Behavior settings
vim.opt.hidden = true                              -- Allow hidden buffers
vim.opt.errorbells = false                         -- No error bells
vim.opt.backspace = "indent,eol,start"             -- Better backspace behavior
vim.opt.autochdir = false                          -- Don't auto change directory
vim.opt.iskeyword:append("-")                      -- Treat dash as part of word
vim.opt.path:append("**")                          -- include subdirectories in search
vim.opt.selection = "exclusive"                    -- Selection behavior
vim.opt.mouse = "a"                                -- Enable mouse support
vim.opt.clipboard:append("unnamedplus")            -- Use system clipboard
vim.opt.modifiable = true                          -- Allow buffer modifications
vim.opt.encoding = "UTF-8"                         -- Set encoding

-- Cursor settings
vim.opt.guicursor = "n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

-- Note: Insert mode completion handled by blink.cmp with preset 'default'
-- This provides: arrow keys navigation, tab navigation, and enter to accept
-- Display invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Folding settings
vim.opt.foldmethod = "expr"              -- Use expression for folding
vim.opt.foldlevel = 99                   -- Start with all folds open

-- Split behavior
vim.opt.splitbelow = true                -- Horizontal splits go below
vim.opt.splitright = true                -- Vertical splits go right

-- ============================================================================
-- Load core configurations
-- ============================================================================
require 'core_plugins'                   -- Snacks.nvim (must load first)
require 'command'                        -- Command palette & history
require 'core_health'                    -- Health checks
require 'core_keymaps'                   -- Key mappings
require 'core_autocmds'                  -- Autocommands utilities
require 'core_lsp'                       -- LSP settings
require 'core_lsp_toggles'              -- LSP action toggles
require 'core_commands'                  -- User commands

-- ============================================================================
-- Load third-party plugins and their configurations in lua/plugins directory.
-- ============================================================================
require 'core_theme'                      -- Theme configurations
require 'plugin_editor'                   -- Editor configurations
require 'plugin_completion'               -- Code completion (blink.cmp + mistral-codestral fork)
require 'plugin_treesitter'               -- Syntax highlighting (nvim-treesitter)
require 'plugin_filemanager'              -- File marks (miniharp)
require 'plugin_fff'                      -- File search (fff)
require 'plugin_lualine'                  -- Statusline (lualine)
require 'plugin_noice'                    -- Cmdline UI replacement (noice)
require 'plugin_vcs'                      -- Version control (git)
require 'plugin_whichkey'                 -- Which-key (keybindings helper)
require 'plugin_mason'                    -- Mason package manager
require 'command_mason_pkg'               -- Mason package manager GUI (depends on mason)
require 'language_rust'                   -- Rust development toolkit
require 'language_typescript'             -- TypeScript/React/Lit/Deno
require 'language_tailwind'               -- Tailwind CSS
require 'language_lit'                    -- Lit Web Component
require 'language_astro'                  -- Astro framework
require 'language_go'                     -- Go language
require 'language_elixir'                 -- Elixir/Phoenix
require 'language_zig'                    -- Zig language
require 'language_sql'                    -- SQL (PostgreSQL/SQLite)
require 'language_protobuf'               -- Protobuf/gRPC
require 'language_terraform'              -- Terraform/HCL
require 'plugin_multicursor'              -- Multiple cursors (jake-stewart/multicursor.nvim)
require 'plugin_mistral_codestral'        -- AI autocompletion (Codestral via blink.cmp)
