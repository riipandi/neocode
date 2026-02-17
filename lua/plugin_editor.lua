vim.pack.add({
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/axieax/urlview.nvim" },
  { src = "https://github.com/laytan/cloak.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
})

-- -- ============================================================================
-- -- Add indentation guides even on blank lines
-- -- ============================================================================
-- require('ibl').setup({
--   exclude = {
--     filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "trouble", "lazy", "mason", "notify", "toggleterm", "lazyterm" },
--     buftypes = { "terminal","nofile","quickfix","prompt" },
--   },
-- })

-- ============================================================================
-- Powerful autopair plugin for Neovim that supports multiple characters.
-- ============================================================================
require('nvim-autopairs').setup({
  enabled = function(bufnr) return true end, -- control if auto-pairs should be enabled when attaching to a buffer
  disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },
  disable_in_macro = true, -- disable when recording or executing a macro
  disable_in_visualblock = false, -- disable when insert after visual block mode
  disable_in_replace_mode = true,
  ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
  enable_moveright = true,
  enable_afterquote = true, -- add bracket pairs after quote
  enable_check_bracket_line = true, --- check bracket in same line
  enable_bracket_in_quote = true, --
  enable_abbr = false, -- trigger abbreviation
  break_undo = true, -- switch for basic rule break undo sequence
  check_ts = false,
  map_cr = true,
  map_bs = true, -- map the <BS> key
  map_c_h = false, -- Map the <C-h> key to delete a pair
  map_c_w = false, -- map <c-w> to delete a pair if possible
})

-- ============================================================================
-- Highlight todo, notes, etc in comments
-- ============================================================================
require('todo-comments').setup({
  signs = false
})

-- ============================================================================
-- Show all the URLs in a buffer
-- ============================================================================
require('urlview').setup({
  -- Prompt title (`<context> <default_title>`, e.g. `Buffer Links:`)
  default_title = "Links:",
  -- Default picker to display links with
  -- Options: "default" (vim.ui.select) or "telescope"
  default_picker = "telescope",
  -- Set the default protocol for us to prefix URLs with if they don't start with http/https
  default_prefix = "https://",
  -- Command or method to open links with
  -- Options: "netrw", "system" (default OS browser); or "firefox", "chromium" etc.
  default_action = "system",
  -- Logs user warnings
  log_level_min = vim.log.levels.INFO,
})

-- ============================================================================
-- Redact sensitive information inside env files
-- ============================================================================
require('cloak').setup({
  enabled = true,
  cloak_character = '*',
  highlight_group = 'Comment',
  cloak_length = 12,
  try_all_patterns = true,
  cloak_telescope = true,
  patterns = {
    {
      file_pattern = '.env*',
      cloak_pattern = '=.+',
    },
  },
})

-- ============================================================================
-- Improve viewing Markdown files
-- ============================================================================
require('render-markdown').setup({
  enabled = false,
  completions = {
    lsp = { enabled = true }
  },
  latex = { enabled = false },
})

-- ============================================================================
-- Lightweight yet powerful formatter plugin for Neovim
-- ============================================================================
require('conform').setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
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
  formatters_by_ft = {
    -- astro = { { "astro", "prettier" } },
    -- blade = { "blade-formatter" }
    -- cpp = {"clang-format"},
    -- css = { { "prettierd", "prettier" } },
    -- elixir = { "mix" },
    -- go = { "goimports", "gofmt" },
    -- haskell = { "ormolu" },
    -- heex = { "mix" },
    -- html = { { "prettierd", "prettier" } },
    -- javascript = { "biome", "biome-organize-imports" },
    -- javascriptreact = { "biome", "biome-organize-imports" },
    -- json = { { "prettierd", "prettier" } },
    -- jsonc = { "prettierd" },
    -- lua = { "stylua" },
    -- mdx = { "prettierd" },
    -- php = { "pretty-php" },
    -- python = { "isort", "black" },
    -- rust = { "rustfmt", lsp_format = "fallback" },
    -- svelte = { "prettierd" },
    -- typescript = { "biome", "biome-organize-imports" },
    -- typescriptreact = { "biome", "biome-organize-imports" },
    -- typst = { "typstyle" },
    -- yaml = { "prettierd" },
  },
  format_after_save = {
    lsp_fallback = true,
    quiet = true,
  },
})

-- keys = {
--   {
--     '<leader>f',
--     function()
--       require('conform').format { async = true, lsp_format = 'fallback' }
--     end,
--     mode = '',
--     desc = '[F]ormat buffer',
--   },
-- },
