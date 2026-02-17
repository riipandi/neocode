vim.pack.add({
  { src = 'https://github.com/rcarriga/nvim-notify' },
  { src = 'https://github.com/folke/noice.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
})

require('notify').setup({
  stages = 'static',
  timeout = 4000,  -- 4 seconds
})

require('noice').setup({
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
    opts = {
      position = {
        row = "50%",
        col = "50%",
      },
    },
    format = {
      cmdline = { pattern = "^:", icon = "", lang = "vim" },
      search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
      search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
      filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
      lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
      help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
      input = {},
    },
  },
  messages = {
    enabled = true,
    view = "notify",
    view_error = "notify",
    view_warn = "notify",
    view_history = "messages",
    view_search = "virtualtext",
  },
  popupmenu = {
    enabled = true,
    backend = "nui",
  },
  presets = {
    bottom_search = false,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = true,
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        find = "E486",
      },
      opts = { skip = true },
    },
  },
  views = {
    cmdline_popup = {
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winblend = 10,
        winhighlight = {
          Normal = "NormalFloat",
          FloatBorder = "FloatBorder",
        },
      },
    },
    popupmenu = {
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winblend = 10,
        winhighlight = {
          Normal = "NormalFloat",
          FloatBorder = "FloatBorder",
        },
      },
      relative = "cursor",
      position = {
        row = 1,
        col = 0,
      },
    },
  },
})

