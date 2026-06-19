-- ============================================================================
-- AI / Mistral Codestral keymaps
-- ============================================================================
-- Mirrors the `MistralCodestral*` user commands and the virtual-text controls
-- as a `<leader>i` ("intelligence") group, so which-key can advertise them.
--
-- All bindings are lazy: they call the user command at dispatch time so the
-- order in init.lua doesn't matter (core_keymaps is loaded before the
-- plugin, but the command exists at the time the user actually presses the
-- key).
--
-- `<leader>m` was avoided to keep this separate from miniharp's file-mark
-- shortcuts (`<leader>ma` toggle, `<leader>mc` clear).
-- ============================================================================

local M = {}

local function setmap(lhs, desc)
	vim.keymap.set("n", lhs, "<Cmd>" .. desc .. "<CR>", { desc = desc, silent = true })
end

-- Manual: force a FIM completion at the cursor
setmap("<leader>ic", "MistralCodestralComplete")

-- Toggle: enable/disable AI completions globally
setmap("<leader>it", "MistralCodestralToggle")

-- Virtual text: trigger / clear the ghost preview
setmap("<leader>iv", "MistralCodestralVirtualComplete")
setmap("<leader>ix", "MistralCodestralVirtualClear")

-- Auth: open the snacks picker (registered in plugin_mistral_codestral.lua)
setmap("<leader>iA", "MistralCodestralAuth")

-- Health: run the fork's :checkhealth-style report
setmap("<leader>ih", "MistralCodestralHealth")

-- Commit message: generate one from the current git diff
setmap("<leader>ig", "MistralCodestralCommitMsg")

return M
