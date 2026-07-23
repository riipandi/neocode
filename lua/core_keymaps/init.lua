-- ============================================================================
-- Core Keymaps (modular)
-- ============================================================================
-- Leader key setup
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load sub-modules in order
require("core_keymaps.general")
require("core_keymaps.undo")
require("core_keymaps.buffer")
require("core_keymaps.quit")
require("core_keymaps.tools")
require("core_keymaps.cmdline")
require("core_keymaps.explorer")
require("core_keymaps.ai") -- Mistral Codestral AI
require("core_keymaps.picker")
