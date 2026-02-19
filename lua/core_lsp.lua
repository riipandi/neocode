-- ============================================================================
-- Core LSP Configuration
-- ============================================================================

local snacks = require("snacks")
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Find project root directory by searching for pattern files
local function find_root(patterns)
  local path = vim.fn.expand('%:p:h')
  local root = vim.fs.find(patterns, { path = path, upward = true })[1]
  return root and vim.fn.fnamemodify(root, ':h') or path
end

-- ============================================================================
-- LSP Server Setup Functions
-- ============================================================================

-- Shell script LSP (bash-language-server)
local function setup_shell_lsp()
  vim.lsp.start({
    name = 'bashls',
    cmd = {'bash-language-server', 'start'},
    filetypes = {'sh', 'bash', 'zsh'},
    root_dir = find_root({'.git', 'Makefile'}),
    settings = {
      bashIde = {
        globPattern = "*@(.sh|.inc|.bash|.command)"
      }
    }
  })
end

-- Python LSP (pylsp)
local function setup_python_lsp()
  vim.lsp.start({
    name = 'pylsp',
    cmd = {'pylsp'},
    filetypes = {'python'},
    root_dir = find_root({'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git'}),
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
              enabled = false
          },
          flake8 = {
              enabled = true,
          },
          black = {
              enabled = true
          }
        }
      }
    }
  })
end

-- ============================================================================
-- Auto-start LSP by Filetype
-- ============================================================================

autocmd('FileType', {
  pattern = 'sh,bash,zsh',
  callback = setup_shell_lsp,
  desc = 'Start shell LSP'
})

autocmd('FileType', {
  pattern = 'python',
  callback = setup_python_lsp,
  desc = 'Start Python LSP'
})

-- ============================================================================
-- Code Formatting
-- ============================================================================

-- Format code using external formatters (black for Python, shfmt for shell)
local function format_code()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype

  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  if filetype == 'python' or filename:match('%.py$') then
    if filename == '' then
      vim.notify("Save the file first before formatting Python", vim.log.levels.WARN)
      return
    end

    local black_cmd = "black --quiet " .. vim.fn.shellescape(filename)
    local black_result = vim.fn.system(black_cmd)

    if vim.v.shell_error == 0 then
      vim.cmd('checktime')
      vim.api.nvim_win_set_cursor(0, cursor_pos)
      vim.notify("Formatted with black", vim.log.levels.INFO)
      return
    else
      vim.notify("No Python formatter available (install black)", vim.log.levels.WARN)
      return
    end
  end

  if filetype == 'sh' or filetype == 'bash' or filename:match('%.sh$') then
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, '\n')

    local cmd = {'shfmt', '-i', '2', '-ci', '-sr'}
    local result = vim.fn.system(cmd, content)

    if vim.v.shell_error == 0 then
      local formatted_lines = vim.split(result, '\n')
      if formatted_lines[#formatted_lines] == '' then
        table.remove(formatted_lines)
      end
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
      vim.api.nvim_win_set_cursor(0, cursor_pos)
      vim.notify("Shell script formatted with shfmt", vim.log.levels.INFO)
      return
    else
      vim.notify("shfmt error: " .. result, vim.log.levels.ERROR)
      return
    end
  end

  vim.notify("No formatter available for " .. filetype, vim.log.levels.WARN)
end

vim.api.nvim_create_user_command("FormatCode", format_code, {
  desc = "Format current file"
})

snacks.keymap.set('n', '<leader>fm', format_code, { desc = 'Format file' })

-- ============================================================================
-- LSP Keymaps
-- ============================================================================

autocmd('LspAttach', {
  callback = function(event)
    local opts = {buffer = event.buf}

    snacks.keymap.set('n', 'gD', vim.lsp.buf.definition, opts)
    snacks.keymap.set('n', 'gs', vim.lsp.buf.declaration, opts)
    snacks.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    snacks.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

    snacks.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    snacks.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    snacks.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    snacks.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

    snacks.keymap.set('n', '<leader>nd', vim.diagnostic.goto_next, opts)
    snacks.keymap.set('n', '<leader>pd', vim.diagnostic.goto_prev, opts)
    snacks.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
    snacks.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
  end,
  desc = 'LSP keymaps',
})

-- ============================================================================
-- Diagnostic Configuration
-- ============================================================================

vim.diagnostic.config({
  virtual_text = { prefix = '●' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✗",
      [vim.diagnostic.severity.WARN] = "⚠",
      [vim.diagnostic.severity.INFO] = "ℹ",
      [vim.diagnostic.severity.HINT] = "💡",
    }
  }
})

vim.diagnostic.config({
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
})

-- ============================================================================
-- Custom Commands
-- ============================================================================

vim.api.nvim_create_user_command('LspInfo', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP clients attached to current buffer", vim.log.levels.WARN)
  else
    for _, client in ipairs(clients) do
      vim.notify("LSP: " .. client.name .. " (ID: " .. client.id .. ")", vim.log.levels.INFO)
    end
  end
end, { desc = 'Show LSP client info' })

-- ============================================================================
-- Additional LSP Servers
-- ============================================================================

-- HTML LSP (superhtml)
autocmd("Filetype", {
  pattern = { "html", "shtml", "htm" },
  callback = function()
    vim.lsp.start({
      name = "superhtml",
      cmd = { "superhtml", "lsp" },
      root_dir = vim.fs.dirname(vim.fs.find({".git"}, { upward = true })[1])
    })
  end,
  desc = 'Start HTML LSP',
})

-- Enable default LSP servers
vim.lsp.enable({
  "bashls",
  "gopls",
  "lua_ls",
  "oxlint",
  "rust-analyzer",
  "texlab",
  "ts_ls",
  "yamlls",
})
