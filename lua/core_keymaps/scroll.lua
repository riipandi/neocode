-- ============================================================================
-- Editor scroll keys: keep them consistent
-- ============================================================================
-- <C-d>/<C-u> (half page) is the reference behaviour. These keys now use the
-- same builtin so a half page means exactly the same thing everywhere:
--
--   <C-d> / <C-u>        half page down/up (native)
--   <S-Down> / <S-Up>    half page (native Shift+Arrow jumps a whole page)
--   } / {                half page (native jumps to the next/previous
--                        paragraph, which lands on a different screen row on
--                        every press)
--
-- Paragraph motion is still available where it matters: these mappings are
-- normal-mode only, so `d}`, `y{`, `v}`, `c{` and friends keep working with
-- operators and in visual mode.
--
-- Everything else stays native: <C-e>/<C-y>, <C-f>, the mouse wheel, insert
-- mode, and the picker/explorer keymaps (core_keymaps/explorer.lua,
-- core_keymaps/picker.lua).

local function feed(keys)
    -- "nx": execute immediately without remapping, so the mapping cannot
    -- recurse into itself.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "nx", false)
end

--- Repeat the half-page builtin as many times as the user typed, so counts
--- keep working (3} == 3<C-d>).
local function half_page(keys)
    local count = vim.v.count
    if count > 1 then
        feed(count .. keys)
    else
        feed(keys)
    end
end

local half_page_down = function()
    half_page("<C-d>")
end

local half_page_up = function()
    half_page("<C-u>")
end

vim.keymap.set("n", "<S-Down>", half_page_down, { desc = "Half page down (same as <C-d>)" })
vim.keymap.set("n", "<S-Up>", half_page_up, { desc = "Half page up (same as <C-u>)" })
vim.keymap.set("n", "}", half_page_down, { desc = "Half page down (same as <C-d>)" })
vim.keymap.set("n", "{", half_page_up, { desc = "Half page up (same as <C-u>)" })
