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
-- (see core_keymaps/folds.lua).
--   <S-CR>    Shift+Enter        - needs the terminal to report Shift+Enter as
--                                  its own key (kitty keyboard protocol)
--   <M-CR>    Option/Alt+Enter   - same action where Shift+Enter is swallowed
--   <M-S-CR>  Option+Shift+Enter - fold/unfold every block in the buffer
--                                  (Ctrl+Shift+Enter is taken by the terminal)
vim.keymap.set("n", "<S-CR>", function()
    require("core_keymaps.folds").toggle()
end, { desc = "Toggle fold under cursor", silent = true })

vim.keymap.set("n", "<M-CR>", function()
    require("core_keymaps.folds").toggle()
end, { desc = "Toggle fold under cursor (Option+Enter)", silent = true })

vim.keymap.set("n", "<M-S-CR>", function()
    require("core_keymaps.folds").toggle_all()
end, { desc = "Toggle all folds", silent = true })
