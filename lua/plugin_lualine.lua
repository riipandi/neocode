-- ============================================================================
-- Customizable neovim statusline plugin.
-- ============================================================================
vim.pack.add({
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/nvim-mini/mini.icons', version = 'stable' },
})

require('nvim-web-devicons').setup({})
require('mini.icons').setup({})

-- Custom lualine theme matching atomizer colors
local custom_theme = {
  normal = {
    a = { fg = "#ffffff", bg = "#336ff1", gui = "bold" },
    b = { fg = "#bcbec4", bg = "#252629" },
    c = { fg = "#bcbec4", bg = "#181a1d" },
    x = { fg = "#bcbec4", bg = "#181a1d" },
    y = { fg = "#bcbec4", bg = "#252629" },
    z = { fg = "#bcbec4", bg = "#252629", gui = "bold" },
  },
  insert = {
    a = { fg = "#ffffff", bg = "#6aab73", gui = "bold" },
    b = { fg = "#bcbec4", bg = "#252629" },
    c = { fg = "#bcbec4", bg = "#181a1d" },
    x = { fg = "#bcbec4", bg = "#181a1d" },
    y = { fg = "#bcbec4", bg = "#252629" },
    z = { fg = "#bcbec4", bg = "#252629", gui = "bold" },
  },
  visual = {
    a = { fg = "#ffffff", bg = "#cf8e6d", gui = "bold" },
    b = { fg = "#bcbec4", bg = "#252629" },
    c = { fg = "#bcbec4", bg = "#181a1d" },
    x = { fg = "#bcbec4", bg = "#181a1d" },
    y = { fg = "#bcbec4", bg = "#252629" },
    z = { fg = "#bcbec4", bg = "#252629", gui = "bold" },
  },
  replace = {
    a = { fg = "#ffffff", bg = "#ffb347", gui = "bold" },
    b = { fg = "#bcbec4", bg = "#252629" },
    c = { fg = "#bcbec4", bg = "#181a1d" },
    x = { fg = "#bcbec4", bg = "#181a1d" },
    y = { fg = "#bcbec4", bg = "#252629" },
    z = { fg = "#bcbec4", bg = "#252629", gui = "bold" },
  },
  command = {
    a = { fg = "#ffffff", bg = "#f85149", gui = "bold" },
    b = { fg = "#bcbec4", bg = "#252629" },
    c = { fg = "#bcbec4", bg = "#181a1d" },
    x = { fg = "#bcbec4", bg = "#181a1d" },
    y = { fg = "#bcbec4", bg = "#252629" },
    z = { fg = "#bcbec4", bg = "#252629", gui = "bold" },
  },
  inactive = {
    a = { fg = "#7a7e85", bg = "#181a1d" },
    b = { fg = "#7a7e85", bg = "#181a1d" },
    c = { fg = "#7a7e85", bg = "#181a1d" },
    x = { fg = "#7a7e85", bg = "#181a1d" },
    y = { fg = "#7a7e85", bg = "#181a1d" },
    z = { fg = "#7a7e85", bg = "#181a1d" },
  },
}

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = custom_theme,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {
        'alpha',
        'dashboard',
        'starter',
      },
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = true,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
      refresh_time = 16,
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'CursorMovedI',
        'ModeChanged',
      },
    }
  },
  sections = {
    lualine_a = {
      {
        "mode",
        fmt = function(str)
          local mode_map = {
            ["NORMAL"] = "N",
            ["INSERT"] = "I",
            ["VISUAL"] = "V",
            ["V-LINE"] = "VL",
            ["V-BLOCK"] = "VB",
            ["SELECT"] = "S",
            ["S-LINE"] = "SL",
            ["S-BLOCK"] = "SB",
            ["REPLACE"] = "R",
            ["COMMAND"] = "C",
            ["TERMINAL"] = "T",
            ["EX"] = "EX",
            ["MORE"] = "M",
            ["CONFIRM"] = "Y?",
          }
          return mode_map[str] or str:sub(1, 1)
        end,
        padding = { left = 1, right = 1 },
      },
    },
    lualine_b = {
      {
        "branch",
        padding = { left = 1, right = 1 }
      },
      {
        "diff",
        padding = { left = 1, right = 1 }
      },
    },
    lualine_c = {
      {
        "filename",
        file_status = true,
        newfile_status = false,
        path = 1,
        shorting_target = 40,
        symbols = {
          modified = "●",
          readonly = "",
          unnamed = "[No Name]",
          newfile = "[New]",
        },
        padding = { left = 1, right = 1 },
      },
      {
        "diff",
        symbols = { added = " ", modified = " ", removed = " " },
        diff_color = {
          added = { fg = "#6A9955" },
          modified = { fg = "#ffb347" },
          removed = { fg = "#f85149" },
        },
        cond = function()
          return vim.fn.winwidth(0) > 80
        end,
      },
    },
    lualine_x = {
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
        diagnostics_color = {
          error = { fg = "#f85149" },
          warn = { fg = "#ff8a00" },
          info = { fg = "#56a8f5" },
          hint = { fg = "#7a7e85" },
        },
        cond = function()
          return vim.fn.winwidth(0) > 80
        end,
      },
      {
        function()
          local msg = "No LSP"
          local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })

          local clients = {}
          if vim.lsp.get_clients then
            clients = vim.lsp.get_clients({ bufnr = 0 })
          else
            clients = vim.lsp.get_active_clients({ bufnr = 0 })
          end

          if next(clients) == nil then
            return msg
          end

          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        icon = " ",
        color = { gui = "bold" },
        cond = function()
          return vim.fn.winwidth(0) > 100
        end,
      },
    },
    lualine_y = {
      {
        "encoding",
        cond = function()
          return vim.fn.winwidth(0) > 100
        end,
        padding = { left = 0, right = 1 },
      },
      {
        "fileformat",
        symbols = {
          unix = "",
          dos = "",
          mac = "",
        },
        cond = function()
          return vim.fn.winwidth(0) > 100
        end,
        padding = { left = 0, right = 1 },
      },
      {
        "filetype",
        padding = { left = 0, right = 1 }
      },
      -- Mistral Codestral AI status
      --   idle      ─ codestral-latest          (dim gray)
      --   waiting   ◐ waiting 1.2s (function)  (orange)
      --   ready     ● ready • function body    (green)
      --   error     ✖ error: <message>         (red)
      {
        function()
          local ok, vt = pcall(require, "mistral-codestral.virtual_text")
          if not ok then return "" end
          local label = vt.status_label()
          -- "icon text" — icon first, then a space, then the label
          if label.icon and label.icon ~= "" then
            return label.icon .. " " .. label.text
          end
          return label.text
        end,
        -- Always show so the user knows the model is wired
        cond = function()
          return pcall(require, "mistral-codestral.virtual_text")
        end,
        color = function()
          local ok, vt = pcall(require, "mistral-codestral.virtual_text")
          if not ok then return { fg = "#7a7e85" } end
          local label = vt.status_label()
          return { fg = label.color }
        end,
        -- Tooltip on hover (lualine supports this)
        on_click = function()
          local ok, m = pcall(require, "mistral-codestral")
          if ok and m and m.config and m.config().enabled then
            vim.cmd("MistralCodestralToggle")
          end
        end,
        on_click_statusline = function()
          local ok, vt = pcall(require, "mistral-codestral.virtual_text")
          if not ok then return "" end
          return vt.status_label().tooltip
        end,
        separator = { left = "" },
        padding = { left = 0, right = 1 },
      },
    },
    lualine_z = {
      {
        "location",
        color = { gui = "bold" },
        padding = { left = 1, right = 1 },
      },
      {
        "progress",
        color = { gui = "bold" },
        padding = { left = 0, right = 1 },
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {
    "neo-tree",
    "lazy",
    "mason",
    "oil",
    "trouble",
    "quickfix",
  },
})

-- Add visual height to statusline via custom highlights
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "#181a1d", fg = "#bcbec4", bold = true })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "#181a1d", fg = "#7a7e85" })
  end,
})

-- Apply highlights immediately
vim.api.nvim_set_hl(0, "StatusLine", { bg = "#181a1d", fg = "#bcbec4", bold = true })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "#181a1d", fg = "#7a7e85" })
