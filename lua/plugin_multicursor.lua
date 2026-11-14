vim.pack.add({
    { src = "https://github.com/jake-stewart/multicursor.nvim" },
})

-- ============================================================================
-- multicursor.nvim: multiple cursors in Neovim
-- Example config adapted from jake-stewart/multicursor.nvim
-- ============================================================================
local mc = require("multicursor-nvim")
mc.setup()

local set = vim.keymap.set

-- Line-based cursor: eksplisit — tidak override arrow default
set({ "n", "x" }, "<leader><up>", function() mc.lineAddCursor(-1) end, { desc = "Multi-cursor: add cursor above" })
set({ "n", "x" }, "<leader><down>", function() mc.lineAddCursor(1) end, { desc = "Multi-cursor: add cursor below" })

-- Same as above on Option+Shift+arrow, the Sublime-style pair. Ghostty with
-- the kitty keyboard protocol reports them as <M-S-Up>/<M-S-Down>; run
-- :KeyProbe when the terminal collapses the Shift.
set({ "n", "x" }, "<M-S-up>", function() mc.lineAddCursor(-1) end, { desc = "Multi-cursor: add cursor above" })
set({ "n", "x" }, "<M-S-down>", function() mc.lineAddCursor(1) end, { desc = "Multi-cursor: add cursor below" })

-- VS Code puts the same action on Ctrl+Alt+arrow. The terminal reports those
-- as CSI 1;7A/CSI 1;7B, which Neovim decodes into one of several modifier
-- spellings, so every alias is mapped.
for _, key in ipairs({ "<C-A-up>", "<M-C-up>", "<C-M-up>" }) do
    set({ "n", "x" }, key, function() mc.lineAddCursor(-1) end, { desc = "Multi-cursor: add cursor above" })
end
for _, key in ipairs({ "<C-A-down>", "<M-C-down>", "<C-M-down>" }) do
    set({ "n", "x" }, key, function() mc.lineAddCursor(1) end, { desc = "Multi-cursor: add cursor below" })
end

-- Add or skip adding a new cursor by matching word/selection
-- mc also triggers matchAddCursor(1) as a faster alternative to <leader>n
set({ "n", "x" }, "mc", function() mc.matchAddCursor(1) end, { desc = "Multi-cursor: add next match" })
set({ "n", "x" }, "<leader>n", function() mc.matchAddCursor(1) end, { desc = "Multi-cursor: add next match" })
set({ "n", "x" }, "<leader>ss", function() mc.matchSkipCursor(1) end, { desc = "Multi-cursor: skip next match" })
set({ "n", "x" }, "<leader>N", function() mc.matchAddCursor(-1) end, { desc = "Multi-cursor: add previous match" })
-- NOTE: <leader>S is used by scratch select — using <leader>M instead
set({ "n", "x" }, "<leader>M", function() mc.matchSkipCursor(-1) end, { desc = "Multi-cursor: skip previous match" })

-- Ctrl+Click: add cursor at mouse position
set("n", "<c-leftmouse>", mc.handleMouse)
set("n", "<c-leftdrag>", mc.handleMouseDrag)
set("n", "<c-leftrelease>", mc.handleMouseRelease)
-- NOTE: <C-q> dipakai untuk quit — toggle cursor tidak dipakai.
-- Keymap layer esc() sudah handle clear cursors.

-- ============================================================================
-- Extended actions
-- ============================================================================

-- Add cursor for ALL matches of word/selection in buffer
set({ "n", "x" }, "<leader>A", mc.matchAllAddCursors, { desc = "Multi-cursor: add all matches" })

-- Align cursor columns
set("n", "<leader>a", mc.alignCursors, { desc = "Multi-cursor: align columns" })


-- Restore last cursor set
set("n", "<leader>gv", mc.restoreCursors, { desc = "Multi-cursor: restore last set" })

-- Append/insert on each line of visual selection
set("x", "I", mc.insertVisual, { desc = "Multi-cursor: insert on each line" })
set("x", "A", mc.appendVisual, { desc = "Multi-cursor: append on each line" })

-- Turn each row of the selection into its own cursor: pick rows with <C-v>
-- (block selection, keeps the column) or V (line start), press <leader>v,
-- then run one edit and it lands on every row.
set("x", "<leader>v", mc.visualToCursors, { desc = "Multi-cursor: selection rows to cursors" })

-- ============================================================================
-- Keymap layer: only active when multiple cursors exist
-- ============================================================================
mc.addKeymapLayer(function(layerSet)
    -- Navigate between cursors
    layerSet({ "n", "x" }, "<left>", mc.prevCursor)
    layerSet({ "n", "x" }, "<right>", mc.nextCursor)

    -- Delete main cursor (<leader>x is the DAP group, hence the capital)
    layerSet({ "n", "x" }, "<leader>X", mc.deleteCursor)

    -- Escape: enable disabled cursors, or clear if already enabled
    layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
            mc.enableCursors()
        else
            mc.clearCursors()
        end
    end)
end)

-- ============================================================================
-- Highlight
-- ============================================================================
local hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor", { reverse = true })
hl(0, "MultiCursorVisual", { link = "Visual" })
hl(0, "MultiCursorSign", { link = "SignColumn" })
hl(0, "MultiCursorMatchPreview", { link = "Search" })
hl(0, "MultiCursorDisabledCursor", { reverse = true })
hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
