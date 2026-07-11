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
set({ "n", "x" }, "<leader><up>", function() mc.lineAddCursor(-1) end)
set({ "n", "x" }, "<leader><down>", function() mc.lineAddCursor(1) end)

-- Add or skip adding a new cursor by matching word/selection
-- mc also triggers matchAddCursor(1) as a faster alternative to <leader>n
set({ "n", "x" }, "mc", function() mc.matchAddCursor(1) end)
set({ "n", "x" }, "<leader>n", function() mc.matchAddCursor(1) end)
set({ "n", "x" }, "<leader>s", function() mc.matchSkipCursor(1) end)
set({ "n", "x" }, "<leader>N", function() mc.matchAddCursor(-1) end)
-- NOTE: <leader>S is used by scratch select — using <leader>M instead
set({ "n", "x" }, "<leader>M", function() mc.matchSkipCursor(-1) end)

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
set({ "n", "x" }, "<leader>A", mc.matchAllAddCursors)

-- Align cursor columns
set("n", "<leader>a", mc.alignCursors)


-- Restore last cursor set
set("n", "<leader>gv", mc.restoreCursors)

-- Append/insert on each line of visual selection
set("x", "I", mc.insertVisual)
set("x", "A", mc.appendVisual)

-- ============================================================================
-- Keymap layer: only active when multiple cursors exist
-- ============================================================================
mc.addKeymapLayer(function(layerSet)
  -- Navigate between cursors
  layerSet({ "n", "x" }, "<left>", mc.prevCursor)
  layerSet({ "n", "x" }, "<right>", mc.nextCursor)

  -- Delete main cursor
  layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

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
