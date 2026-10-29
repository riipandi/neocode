-- ============================================================================
-- Core Keymaps (modular)
-- ============================================================================
-- Leader keys are set in init.lua (must happen before any module runs).

-- Load sub-modules in order
require("core_keymaps.general")
require("core_keymaps.scroll")
require("core_keymaps.undo")
require("core_keymaps.buffer")
require("core_keymaps.quit")
require("core_keymaps.tools")
require("core_keymaps.cmdline")
require("core_keymaps.explorer")
require("core_keymaps.ai") -- Mistral Codestral AI
require("core_keymaps.picker")

-- Smart fold toggle: works on any row, not only on a fold header
-- (see core_keymaps/folds.lua). Needs a terminal that forwards Shift+Enter as
-- its own key (kitty keyboard protocol, e.g. Ghostty); otherwise the key
-- arrives as <CR> and this mapping simply never matches.
vim.keymap.set("n", "<S-CR>", function()
    require("core_keymaps.folds").toggle()
end, { desc = "Toggle fold under cursor", silent = true })
