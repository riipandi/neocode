-- ============================================================================
-- Snacks Picker Overrides
-- ============================================================================
-- Overrides for snacks.picker behavior:
--   <C-q>/<A-q> in picker: trigger confirm_quit instead of native qflist
--   `e` in picker list: switch focus to editor window
--   <C-d>/<C-u> in all pickers: jump 2 items (when source has no mapping)
-- ============================================================================
local snacks = require("snacks")
local M = {}

-- Lazy-load confirm_quit from quit module to avoid circular deps
local function get_confirm_quit()
  return require("core_keymaps.quit").confirm_quit
end

-- Apply picker keymap overrides
local function apply_overrides()
  local picker_config = require("snacks").config.picker
  picker_config.win = picker_config.win or {}
  picker_config.win.list = picker_config.win.list or {}
  picker_config.win.input = picker_config.win.input or {}
  picker_config.win.list.keys = picker_config.win.list.keys or {}
  picker_config.win.input.keys = picker_config.win.input.keys or {}

  -- <C-q>/<A-q> confirm quit in picker buffers
  picker_config.win.list.keys["<C-q>"] = get_confirm_quit()
  picker_config.win.list.keys["<A-q>"] = get_confirm_quit()
  picker_config.win.input.keys["<C-q>"] = { get_confirm_quit(), mode = { "i", "n" } }
  picker_config.win.input.keys["<A-q>"] = { get_confirm_quit(), mode = { "i", "n" } }

  -- `e` moves focus to editor window from picker
  picker_config.win.list.keys["e"] = function(_picker)
    vim.cmd("wincmd p")
  end
end

-- Apply once on module load
apply_overrides()
return M
