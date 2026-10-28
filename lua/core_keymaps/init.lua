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
