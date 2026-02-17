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

  local function collapse_folder()
    local node = api.tree.get_node_under_cursor()
    if node.name == ".." then
      return
    end
    api.node.navigate.parent_close()
  end

  local function expand_folder()
    local node = api.tree.get_node_under_cursor()
    if node.nodes then
      api.node.open.edit()
    end
  end

  -- Setup custom mappings (not using default_on_attach)
  vim.keymap.set('n', '<Left>',  collapse_folder,                       opts('Collapse'))
  vim.keymap.set('n', '<Right>', expand_folder,                        opts('Expand'))
  vim.keymap.set('n', 'h',       collapse_folder,                       opts('Collapse'))
  vim.keymap.set('n', 'l',       expand_folder,                        opts('Expand'))
  vim.keymap.set('n', '<CR>',    api.node.open.edit,                    opts('Open'))
  vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit,            opts('Open'))
  vim.keymap.set('n', 'q',       api.tree.close,                       opts('Close'))
  vim.keymap.set('n', 'g?',      api.tree.toggle_help,                opts('Help'))
  vim.keymap.set('n', 'dd',      api.fs.remove,                        opts('Delete'))
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
})

vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'nvim-tree: toggle file explorer' })
