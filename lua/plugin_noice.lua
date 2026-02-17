-- ============================================================================
-- Noice.nvim: cmdline replacement with floating UI
-- ============================================================================
-- Replaces native cmdline with floating popup, allowing cmdheight=0
-- Keeps statusbar at bottom, freeing up vertical space for editing

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

  messages = {
    enabled = false,
  },

  popupmenu = {
    enabled = true,
  },

  lsp = {
    progress = {
      enabled = false,
    },
    hover = {
      enabled = false,
    },
    signature = {
      enabled = false,
    },
    message = {
      enabled = false,
    },
  },

  notify = {
    enabled = false,
  },

  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "",
      },
      opts = { skip = true },
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
