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
vim.opt.number = true                              -- Line numbers
vim.opt.relativenumber = false                     -- Relative line numbers
vim.opt.cursorline = true                          -- Highlight current line
vim.opt.wrap = false                               -- Don't wrap lines
vim.opt.scrolloff = 0                              -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 4                          -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2                                -- Tab width
vim.opt.shiftwidth = 2                             -- Indent width
vim.opt.softtabstop = 2                            -- Soft tab stop
vim.opt.expandtab = true                           -- Use spaces instead of tabs
vim.opt.smartindent = true                         -- Smart auto-indenting
vim.opt.autoindent = true                          -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true                          -- Case insensitive search
vim.opt.smartcase = true                           -- Case sensitive if uppercase in search
vim.opt.hlsearch = false                           -- Don't highlight search results
vim.opt.incsearch = true                           -- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true                       -- Enable 24-bit colors
vim.opt.signcolumn = "yes:1"                       -- Always show sign column
vim.opt.colorcolumn = "0"                          -- Show column ruler (n characters)

-- Completion menu settings
vim.opt.wildmenu = true                            -- Enable wildmenu for command completion
vim.opt.wildmode = "longest:full,full"             -- Complete longest common match, then list all
vim.opt.wildoptions = "pum"                        -- Use popup menu for completions
vim.opt.pumheight = 15                             -- Max items in popup menu
vim.opt.pumblend = 10                              -- Transparency for popup menu
vim.opt.completeopt = "menuone,noinsert,noselect,preview"  -- Completion options
vim.opt.showmatch = true                           -- Highlight matching brackets
vim.opt.matchtime = 2                              -- How long to show matching bracket
vim.opt.cmdheight = 1                              -- Command line height
vim.opt.showmode = false                           -- Don't show the mode, since it's already in the status line
vim.opt.winblend = 0                               -- Floating window transparency
vim.opt.conceallevel = 0                           -- Don't hide markup
vim.opt.concealcursor = ""                         -- Don't hide cursor line markup
vim.opt.lazyredraw = false                         -- Don't redraw during macros
vim.opt.synmaxcol = 300                            -- Syntax highlighting limit
vim.opt.fillchars:append({ eob = " " })            -- Hide tilde character (~) on empty lines
vim.opt.winborder = "rounded"                      -- Set window border style to rounded
vim.g.border_style = "rounded"                     -- Set global border style for floating windows
vim.g.markdown_recommended_style = 0               -- Fix markdown indentation settings

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

-- Command line completion with cursor navigation
vim.api.nvim_create_autocmd("CmdlineEnter", {
  callback = function()
    vim.opt.pumheight = 15
  end,
})

-- Setup cmdline keymaps for popupmenu navigation
local function map_cmdline_nav(keys, pum_action, fallback)
  vim.keymap.set("c", keys, function()
    if vim.fn.pumvisible() == 1 then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(pum_action, true, true, true), "n", true)
      return ""
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(fallback, true, true, true), "n", true)
      return ""
    end
  end, { noremap = true, silent = true })
end

-- Arrow keys for navigation (sesuai preferensi: kiri=up, kanan=down)
map_cmdline_nav("<Down>", "<C-n>", "<Down>")
map_cmdline_nav("<Up>", "<C-p>", "<Up>")
map_cmdline_nav("<Left>", "<C-p>", "<Left>")
map_cmdline_nav("<Right>", "<C-n>", "<Right>")
map_cmdline_nav("<Tab>", "<C-n>", "<Tab>")
map_cmdline_nav("<S-Tab>", "<C-p>", "<S-Tab>")

-- Enter for selection, Esc to cancel
map_cmdline_nav("<CR>", "<C-y>", "<CR>")
map_cmdline_nav("<Esc>", "<C-e>", "<Esc>")

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
require 'core_health'                    -- Health checks
require 'core_keymaps'                   -- Key mappings
require 'core_autocmds'                  -- Autocommands utilities
require 'core_lsp'                       -- LSP settings

-- ============================================================================
-- Load third-party plugins and their configurations in lua/plugins directory.
-- ============================================================================
require 'core_theme'                      -- Theme configurations
require 'plugin_editor'                   -- Editor configurations
require 'plugin_completion'               -- Code completion (blink.cmp)
require 'plugin_treesitter'               -- Syntax highlighting (nvim-treesitter)
require 'plugin_filemanager'              -- File marks (miniharp)
require 'plugin_lualine'                  -- Statusline (lualine)
require 'plugin_neoscroll'                -- Smooth scrolling (neoscroll)
require 'plugin_vcs'                      -- Version control (git)
require 'plugin_whichkey'                 -- Which-key (keybindings helper)
require 'plugin_maple'                    -- Notes plugin (maple)
require 'plugin_mason'                    -- Mason package manager
require 'plugin_opencode'                 -- AI code assistant (OpenCode)
require 'language_rust'                   -- Rust development toolkit
