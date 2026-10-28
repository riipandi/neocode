-- ============================================================================
-- Editor scroll keys: keep them consistent
-- ============================================================================
-- Native <S-Up>/<S-Down> move a whole page while <C-d>/<C-u> move half a page,
-- so the two pairs never matched. Route the arrows through the same builtin as
-- <C-d>/<C-u> (a jump of about half the window, which is "far enough" without
-- losing context).
--
-- Everything else stays native: <C-e>/<C-y>, <C-f>, <C-d>/<C-u>, the mouse
-- wheel, and the ability to scroll past the last line.
--
-- Normal mode only:
--   * insert mode keeps its native Shift+Arrow behaviour
--   * visual mode keeps extending the selection
--   * the picker/explorer keymaps are untouched (they live in
--     core_keymaps/explorer.lua and core_keymaps/picker.lua)

local function feed(keys)
    -- "nx": execute immediately without remapping, so the mapping cannot
    -- recurse into itself.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "nx", false)
end

vim.keymap.set("n", "<S-Down>", function()
    feed("<C-d>")
end, { desc = "Half page down (same as <C-d>)" })

vim.keymap.set("n", "<S-Up>", function()
    feed("<C-u>")
end, { desc = "Half page up (same as <C-u>)" })
