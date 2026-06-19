-- ============================================================================
-- Noice.nvim: cmdline replacement with floating UI
-- ============================================================================
-- Replaces native cmdline with floating popup, allowing cmdheight=0
-- Also intercepts messages for toast-like notifications (undo/redo, search)

local noice = require("noice")

noice.setup({
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
    opts = {
      position = {
        row = "50%",
        col = "50%",
      },
      size = {
        width = "auto",
        height = "auto",
        max_height = 10,
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winblend = 10,
        winhighlight = {
          NormalFloat = "NormalFloat",
          FloatBorder = "FloatBorder",
        },
      },
    },
    format = {
      cmdline = { pattern = "^:", icon = "", lang = "vim" },
      search_down = { pattern = "^/", icon = "", lang = "regex" },
      search_up = { pattern = "^%?", icon = "", lang = "regex" },
      filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
      lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
      help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
    },
  },

  -- Messages: route undo/redo and search results to mini toast
  messages = {
    enabled = true,
    view = "messages",
    view_search = "mini",
    view_history = "messages",
    view_error = "mini",
    view_warn = "mini",
  },

  popupmenu = {
    enabled = true,
  },

  lsp = {
    progress = { enabled = false },
    hover = { enabled = false },
    signature = { enabled = false },
    message = { enabled = false },
  },

  -- Keep disabled — snacks.notifier handles vim.notify calls
  notify = {
    enabled = false,
  },

  routes = {
    -- Undo/redo: mini toast
    { filter = { event = "msg_show", find = "change;" }, view = "mini" },
    { filter = { event = "msg_show", find = "already at" }, view = "mini" },
    -- Substitute count
    { filter = { event = "msg_show", find = "substitution" }, view = "mini" },
    -- Search hit (extra guard beyond view_search)
    { filter = { event = "msg_show", find = "search hit" }, view = "mini" },
    -- Save confirmation: mini toast
    { filter = { event = "msg_show", find = "written" }, view = "mini" },
    { filter = { event = "msg_show", find = "appended" }, view = "mini" },
    -- Yank confirmation
    { filter = { event = "msg_show", find = "yanked" }, view = "mini" },
    -- Backup: any other error messages → mini toast
    { filter = { error = true }, view = "mini" },
  },

  views = {
    mini = {
      backend = "mini",
      relative = "editor",
      align = "message-right",
      position = { row = -2, col = -2 },
      win_options = {
        winblend = 10,
      },
    },
  },

  presets = {
    bottom_search = false,
    command_palette = false,
    long_message_to_split = false,
    inc_rename = false,
    lsp_doc_border = false,
  },

  throttle = 1000 / 30,
})
