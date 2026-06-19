-- ============================================================================
-- LSP Action Toggles
-- ============================================================================
-- Quick toggles for common LSP-related features.
-- Each toggle is a keymap that flips a state and shows a notification.
-- ============================================================================
local snacks = require("snacks")
local M = {}

-- State for toggles
local state = {
  inlay_hints = false,
  diagnostics = true,
  semantic_tokens = true,
  format_on_save = true,
  smooth_scroll = false,
}

-- Generic toggle helper
local function toggle_setting(name, current, on_change)
  local new_value = not current
  state[name] = new_value
  if on_change then on_change(new_value) end
  local status = new_value and "ON" or "OFF"
  Snacks.notify.info(string.format("%s: %s", name:gsub("_", " "):gsub("^%l", string.upper), status))
end

-- Inlay Hints: requires snacks inlay to be enabled
local function toggle_inlay()
  toggle_setting("inlay_hints", state.inlay_hints, function(enabled)
    pcall(vim.lsp.inlay_hint.enable, enabled)
  end)
end

-- Diagnostics (show virtual text for errors/warnings)
local function toggle_diagnostics()
  toggle_setting("diagnostics", state.diagnostics, function(enabled)
    vim.diagnostic.enable(enabled)
  end)
end

-- Format on save
local function toggle_format_on_save()
  toggle_setting("format_on_save", state.format_on_save, function(enabled)
    vim.g.auto_format = enabled
  end)
end

-- Smooth scroll (animate cursor movement)
local function toggle_smooth_scroll()
  toggle_setting("smooth_scroll", state.smooth_scroll, function(enabled)
    vim.opt.smoothscroll = enabled
  end)
end

-- Show LSP info (existing LspInfo command enhanced)
local function show_lsp_info()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    Snacks.notify.warn("No LSP clients attached")
    return
  end
  for _, client in ipairs(clients) do
    local info = {
      string.format("Client #%d: %s", client.id, client.name),
      string.format("  Root: %s", client.root_dir or "?"),
      string.format("  Config: %s", vim.inspect(client.config) and "set" or "default"),
    }
    Snacks.notify.info(table.concat(info, "\n"))
  end
end

-- Keymaps
snacks.keymap.set("n", "<leader>li", toggle_inlay, { desc = "Toggle inlay hints" })
snacks.keymap.set("n", "<leader>ld", toggle_diagnostics, { desc = "Toggle diagnostics" })
snacks.keymap.set("n", "<leader>lf", toggle_format_on_save, { desc = "Toggle format on save" })
snacks.keymap.set("n", "<leader>ls", toggle_smooth_scroll, { desc = "Toggle smooth scroll" })
snacks.keymap.set("n", "<leader>lI", show_lsp_info, { desc = "Show LSP client info" })

return M
