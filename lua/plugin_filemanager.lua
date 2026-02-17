vim.pack.add({
  { src = 'https://github.com/vieitesss/miniharp.nvim' },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
})

-- ============================================================================
-- Mini harpoon-like plugin for Neovim, faster navigation between files.
-- ============================================================================
require('miniharp').setup({
  autoload = true,             -- load marks for this cwd on startup (default: true)
  autosave = true,             -- save marks for this cwd on exit (default: true)
  show_on_autoload = true,     -- show popup list after a successful autoload (default: false)
})

vim.keymap.set('n', '<leader>ma', require('miniharp').toggle_file, { desc = 'miniharp: toggle file mark' })
vim.keymap.set('n', '<leader>mc', require('miniharp').clear,       { desc = 'miniharp: clear file mark' })
vim.keymap.set('n', '<C-l>',     require('miniharp').show_list,    { desc = 'miniharp: list marks' })
vim.keymap.set('n', '<C-n>',     require('miniharp').next,         { desc = 'miniharp: next file mark' })
vim.keymap.set('n', '<C-S-m>',   require('miniharp').prev,         { desc = 'miniharp: prev file mark' })

-- ============================================================================
-- Fuzzy picker using fzf-lua
-- ============================================================================
local fzf_actions = require('fzf-lua.actions')
require('fzf-lua').setup({
   { "telescope", "fzf-native", "border-fused" },
  winopts = {
    preview = {
      default = "bat",
      border = "rounded",
      wrap = false,
      scrollbar = "float",
      scrolloff = -1,
    },
    backdrop  = 85,
    height    = 0.85,    -- window height
    width     = 0.80,    -- window width
    row       = 0.50,    -- window row position (0=top, 1=bottom)
    col       = 0.50,    -- window col position (0=left, 1=right)
  },
  hls = { border = "FloatBorder" },
  keymap = {
    builtin = {
      ["<C-f>"] = "preview-page-down",
      ["<C-b>"] = "preview-page-up",
      ["<C-p>"] = "toggle-preview",
    },
    fzf = {
      ["ctrl-a"] = "toggle-all",
      ["ctrl-t"] = "first",
      ["ctrl-g"] = "last",
      ["ctrl-d"] = "half-page-down",
      ["ctrl-u"] = "half-page-up",
    }
  },
  actions = {
    files = {
      ["ctrl-q"] = fzf_actions.file_sel_to_qf,
      ["ctrl-n"] = fzf_actions.toggle_ignore,
      ["ctrl-h"] = fzf_actions.toggle_hidden,
      ["enter"]  = fzf_actions.file_edit_or_qf,
    }
  },
})

vim.keymap.set("n", "<C-p>", '<cmd>FzfLua files<CR>', { desc = 'fzf-lua: find files' })
vim.keymap.set("n", "<leader>ff", '<cmd>FzfLua files<CR>')
vim.keymap.set("n", "<leader>fg", '<cmd>FzfLua live_grep<CR>')
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>")

vim.keymap.set("n", "<leader>fr", function()
    require("fzf-lua").files({
        actions = {
            ["default"] = function(selected)
                local file = selected[1]
                local rel_path = vim.fn.fnamemodify(file, ":.")

                rel_path = rel_path:gsub(" ", "\\ ")
                if not rel_path:match("^%.?/") then
                    rel_path = "./" .. rel_path
                end

                vim.api.nvim_put({ rel_path }, "l", true, false)
            end,
        },
    })
end)


-- ============================================================================
-- Highly extendable fuzzy finder over lists.
-- ============================================================================
require('telescope').setup({
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
})

-- ============================================================================
-- File explorer tree
-- ============================================================================
-- disable netrw (vim's builtin file explorer) at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- nvim-tree are applied by default however you may customise via `on_attach`
local function custom_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  local function is_protected(node)
    return node.name == ".." or (node.parent == nil)
  end

  local function collapse_folder()
    local node = api.tree.get_node_under_cursor()
    if is_protected(node) then
      return
    end
    api.node.navigate.parent_close()
  end

  local function expand_folder()
    local node = api.tree.get_node_under_cursor()
    if is_protected(node) then
      return
    end
    -- Expand by opening node (works for both files and folders)
    api.node.open.edit()
  end

  local function open_file()
    local node = api.tree.get_node_under_cursor()
    if is_protected(node) then
      return
    end
    api.node.open.edit()
  end

  -- Setup custom mappings (not using default_on_attach)
  vim.keymap.set('n', '<Left>',  collapse_folder,                       opts('Collapse'))
  vim.keymap.set('n', '<Right>', expand_folder,                        opts('Expand'))
  vim.keymap.set('n', 'h',       collapse_folder,                       opts('Collapse'))
  vim.keymap.set('n', 'l',       expand_folder,                        opts('Expand'))
  vim.keymap.set('n', '<CR>',    open_file,                               opts('Open'))
  vim.keymap.set('n', '<2-LeftMouse>', open_file,                    opts('Open'))
  vim.keymap.set('n', 'q',       api.tree.close,                       opts('Close'))
  vim.keymap.set('n', 'g?',      api.tree.toggle_help,                opts('Help'))

  -- File operations
  vim.keymap.set('n', 'a',       function() api.fs.create() end,       opts('Create'))
  vim.keymap.set('n', 'd',       function() api.fs.remove() end,       opts('Delete'))
  vim.keymap.set('n', 'r',       function() api.fs.rename() end,       opts('Rename'))
  vim.keymap.set('n', 'x',       function() api.fs.cut() end,           opts('Cut'))
  vim.keymap.set('n', 'p',       function() api.fs.paste() end,         opts('Paste'))
  vim.keymap.set('n', 'yy',      function() api.fs.copy.node() end,     opts('Copy Name'))
  vim.keymap.set('n', 'yn',      function() api.fs.copy.filename() end, opts('Copy Filename'))
  vim.keymap.set('n', 'yp',      function() api.fs.copy.absolute_path() end, opts('Copy Absolute Path'))
  vim.keymap.set('n', 'y.',      function() api.fs.copy.relative_path() end, opts('Copy Relative Path'))

  -- Navigation
  -- Note: Change directory is disabled in config to prevent parent access
  vim.keymap.set('n', 'J',       function() api.node.navigate.sibling.next() end, opts('Next Sibling'))
  vim.keymap.set('n', 'K',       function() api.node.navigate.sibling.prev() end, opts('Prev Sibling'))
  vim.keymap.set('n', '<C-v>',   function() api.node.open.vertical() end, opts('Open: Vertical Split'))
  vim.keymap.set('n', '<C-s>',   function() api.node.open.horizontal() end, opts('Open: Horizontal Split'))
  vim.keymap.set('n', '<C-t>',   function() api.node.open.tab() end, opts('Open: New Tab'))
  -- Ctrl+E is used globally for switch focus (see core_keymaps.lua)

  -- Tree operations
  vim.keymap.set('n', '<C-k>',   function() api.tree.toggle_custom_filter() end, opts('Toggle Filter'))
  vim.keymap.set('n', 'f',       function() api.live_filter.start() end, opts('Filter'))
  vim.keymap.set('n', 'F',       function() api.live_filter.clear() end, opts('Clean Filter'))
  vim.keymap.set('n', '[c',      function() api.node.navigate.git.prev() end, opts('Prev Git'))
  vim.keymap.set('n', ']c',      function() api.node.navigate.git.next() end, opts('Next Git'))
  vim.keymap.set('n', 's',       function() api.node.run.system() end, opts('Run System'))
  vim.keymap.set('n', 'u',       function() api.tree.toggle_hidden_filter() end, opts('Toggle Dotfiles'))
  vim.keymap.set('n', 'W',       function() api.tree.collapse_all() end, opts('Collapse'))
  vim.keymap.set('n', 'E',       function() api.tree.expand_all() end, opts('Expand All'))
  vim.keymap.set('n', 'R',       function() api.tree.reload() end, opts('Refresh'))
end

require('nvim-tree').setup({
  on_attach = custom_on_attach,
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 34,
  },
  renderer = {
      group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
  -- Restrict nvim-tree to current working directory only
  respect_buf_cwd = false,
  sync_root_with_cwd = false,
  update_focused_file = {
    enable = false,
  },
  -- Prevent navigation to parent directories
  actions = {
    change_dir = {
      enable = false,    -- ❌ Prevent cd to parent
      global = false,
    },
    open_file = {
      quit_on_open = false,
      resize_window = false,
    },
  },
  -- Don't follow symlinks to parent directories
  filesystem_watchers = {
    enable = true,
  },
})

vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'nvim-tree: toggle file explorer' })
