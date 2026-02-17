-- Editor enhancement plugins

vim.pack.add({
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/axieax/urlview.nvim" },
  { src = "https://github.com/laytan/cloak.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
})

-- Indentation guides are now handled by snacks.indent (see plugin_snacks.lua)

-- ============================================================================
-- Auto-pair plugin for brackets, quotes, etc.
-- ============================================================================
require('nvim-autopairs').setup({
  enabled = function(bufnr) return true end,
  disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },
  disable_in_macro = true,
  disable_in_visualblock = false,
  disable_in_replace_mode = true,
  ignored_next_char = [=[[%w%%%'%[%-%."`%$]]=],
  enable_moveright = true,
  enable_afterquote = true,
  enable_check_bracket_line = true,
  enable_bracket_in_quote = true,
  enable_abbr = false,
  break_undo = true,
  check_ts = false,
  map_cr = true,
  map_bs = true,
  map_c_h = false,
  map_c_w = false,
})

-- ============================================================================
-- Highlight todo, notes, etc in comments
-- ============================================================================
require('todo-comments').setup({
  signs = false
})

-- ============================================================================
-- Show all URLs in a buffer
-- ============================================================================
require('urlview').setup({
  default_title = "Links:",
  default_picker = "default",
  default_prefix = "https://",
  default_action = "system",
  log_level_min = vim.log.levels.INFO,
})

-- ============================================================================
-- Redact sensitive information in env files
-- ============================================================================
require('cloak').setup({
  enabled = true,
  cloak_character = '*',
  highlight_group = 'Comment',
  cloak_length = 12,
  try_all_patterns = true,
  patterns = {
    {
      file_pattern = '.env*',
      cloak_pattern = '=.+',
    },
  },
})

-- ============================================================================
-- Code formatter
-- ============================================================================
require('conform').setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    else
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end
  end,
  formatters_by_ft = {},
  format_after_save = {
    lsp_fallback = true,
    quiet = true,
  },
})
