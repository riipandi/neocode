--[[

This is a personal Neovim configuration for Aris Ripandi (@riipandi).

  This configuration based on Kickstart.nvim. Kickstart.nvim is a starting point
  for your own configuration. The goal is that you can read every line of code,
  top-to-bottom, understand what your configuration is doing, and modify it to
  suit your needs.

Requires Neovim 0.12+

--]]

-- Leader keys must be defined before any module registers a mapping,
-- otherwise `<leader>` resolves to the default "\\" for those mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Theme/highlights are owned by core_theme.lua. Setting highlight groups here
-- had no effect: the colourscheme calls `hi clear` and re-defines them.

-- Basic settings
vim.opt.number = true          -- Line numbers
vim.opt.relativenumber = false -- Relative line numbers
vim.opt.cursorline = true      -- Highlight current line
vim.opt.wrap = false           -- Don't wrap lines
-- No context margin: with scrolloff > 0 Vim must keep that many lines around
-- the cursor, so at the end of a buffer it scrolls into the area below the last
-- line and drags the cursor along (visible as the cursor jumping rows). 0 keeps
-- scrolling 1:1 with the cursor and lets core_scroll.lua stop at the last line.
vim.opt.scrolloff = 0
vim.opt.sidescrolloff = 4      -- Keep 4 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2        -- Tab width
vim.opt.shiftwidth = 2     -- Indent width
vim.opt.softtabstop = 2    -- Soft tab stop
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true  -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true  -- Case sensitive if uppercase in search
vim.opt.hlsearch = false  -- Don't highlight search results
vim.opt.incsearch = true  -- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.signcolumn = "yes:1" -- Always show sign column

-- Completion menu settings
vim.opt.wildmenu = true                                   -- Enable wildmenu for command completion
vim.opt.wildmode = "noselect:lastused,full"               -- Suggest as you type, select nothing until <Tab>
vim.opt.wildoptions = "pum"                               -- Use popup menu for completions
vim.opt.pumheight = 15                                    -- Max items in popup menu
vim.opt.pumblend = 10                                     -- Transparency for popup menu
vim.opt.completeopt = "menuone,noinsert,noselect,preview" -- Completion options
vim.opt.cmdheight = 0                                     -- Command line height (noice handles UI)
vim.opt.showmode = false                                  -- Don't show the mode, since it's already in the status line
vim.opt.conceallevel = 0                                  -- Don't hide markup
vim.opt.concealcursor = ""                                -- Don't hide cursor line markup
vim.opt.synmaxcol = 300                                   -- Syntax highlighting limit
-- Blank end-of-buffer area (no `~` marker). Safe now that core_scroll.lua
-- stops <C-e>/<C-f>/wheel from scrolling past the last line.
vim.opt.fillchars:append({ eob = " " })
vim.opt.winborder = "rounded"                             -- Set window border style to rounded
vim.g.border_style = "rounded"                            -- Set global border style for floating windows
vim.g.markdown_recommended_style = 0                      -- Fix markdown indentation settings

-- File handling
vim.opt.backup = false                            -- Don't create backup files
vim.opt.writebackup = false                       -- Don't create backup before writing
vim.opt.swapfile = false                          -- Don't create swap files
vim.opt.undofile = true                           -- Persistent undo (stdpath("state")/undo)
vim.opt.updatetime = 300                          -- Faster completion
vim.opt.timeoutlen = 500                          -- Key timeout duration
vim.opt.ttimeoutlen = 10                          -- Key code timeout (0 breaks Alt keys over SSH)
vim.opt.autoread = true                           -- Auto reload files changed outside vim
vim.opt.autowrite = false                         -- Don't auto save
vim.opt.confirm = true                            -- Raise dialog to save changes

-- Behavior settings
-- Nerd Font is available (devicons, bullets, git bars), so component signs in
-- the gutter use icons instead of the default E/W/I/H letters.
vim.g.have_nerd_font = true
vim.opt.hidden = true                   -- Allow hidden buffers
vim.opt.backspace = "indent,eol,start"  -- Better backspace behavior
-- h / <Left> at the first column continue at the end of the previous line, and
-- l / <Right> at the last character continue at the start of the next line
-- (editor-style wrap). `[` and `]` are the same for <Left> / <Right> in insert
-- and replace mode. Counts and operators carry across the boundary too.
vim.opt.whichwrap:append("h,<,l,>,[,]")
vim.opt.autochdir = false               -- Don't auto change directory
vim.opt.mouse = "a"                     -- Enable mouse support
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard

-- Cursor settings
vim.opt.guicursor =
"n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

-- Note: Insert mode completion handled by blink.cmp with preset 'default'
-- This provides: arrow keys navigation, tab navigation, and enter to accept
-- Display invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Folding: treesitter folds are switched on per window by the FileType hook in
-- plugin_treesitter.lua, so terminals and pickers do not evaluate foldexpr.
vim.opt.foldlevel = 99 -- Start with all folds open

-- Language providers nobody uses (silences :checkhealth warnings)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- Split behavior
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

-- ============================================================================
-- Load core configurations
-- ============================================================================
require 'core_scroll'      -- Scroll bounds: must run before snacks.scroll hooks
require 'core_plugins'     -- Snacks.nvim (must load first)
require 'core_notify'      -- Fold mason-tool-installer toasts into one
require 'command'          -- Command palette & history
require 'core_keymaps'     -- Key mappings
require 'core_autocmds'    -- Autocommands utilities
require 'core_splash'       -- Intro screen + explorer sidebar on startup
require 'core_session'      -- Restore a project's buffers and pins
require 'core_lsp'         -- LSP settings
require 'core_lsp_toggles' -- LSP action toggles
require 'core_commands'    -- User commands

-- ============================================================================
-- Load third-party plugins and their configurations in lua/plugins directory.
-- ============================================================================
require 'core_theme'               -- Theme configurations
require 'core_dim'                 -- Dim inactive splits
require 'plugin_editor'            -- Editor configurations
require 'plugin_completion'        -- Code completion (blink.cmp + mistral-codestral fork)
require 'plugin_treesitter'        -- Syntax highlighting (nvim-treesitter)
require 'plugin_filemanager'       -- File marks (miniharp)
require 'plugin_fff'               -- File search (fff)
require 'plugin_lualine'           -- Statusline (lualine)
require 'plugin_noice'             -- Cmdline UI replacement (noice)
require 'plugin_vcs'               -- Version control (git)
require 'plugin_whichkey'          -- Which-key (keybindings helper)
require 'plugin_markdown'          -- Markdown preview (mdkite.nvim)
require 'plugin_mason'             -- Mason package manager
require 'command_mason_pkg'        -- Mason package manager GUI (depends on mason)
require 'language_rust'            -- Rust development toolkit
require 'language_typescript'      -- TypeScript/React/Lit/Deno
require 'language_tailwind'        -- Tailwind CSS
require 'language_go'              -- Go language
require 'language_servers'         -- Astro, Protobuf, SQL, Terraform, Zig (defaults)
require 'language_elixir'          -- Elixir/Phoenix
require 'plugin_dap'               -- Debugging (nvim-dap + ElixirLS debug adapter)
require 'plugin_multicursor'       -- Multiple cursors (jake-stewart/multicursor.nvim)
require 'plugin_mistral_codestral' -- AI autocompletion (Codestral via blink.cmp)
