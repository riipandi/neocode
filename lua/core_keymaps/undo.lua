-- ============================================================================
-- Undo/Redo with toast notification
-- ============================================================================
local snacks = require("snacks")

local function notify_undo()
  local count = vim.v.count > 0 and vim.v.count or nil
  local seq = vim.fn.undotree().seq_last
  vim.cmd("silent! undo" .. (count and " " .. count or ""))
  local actual = seq - vim.fn.undotree().seq_last
  if actual > 0 then
    vim.notify("Undo " .. actual .. " change" .. (actual ~= 1 and "s" or ""), vim.log.levels.INFO, {
      title = "Undo",
      timeout = 2000,
    })
  else
    vim.notify("Already at oldest change", vim.log.levels.WARN, {
      title = "Undo",
      timeout = 2000,
    })
  end
end

local function notify_redo()
  local count = vim.v.count > 0 and vim.v.count or nil
  local seq = vim.fn.undotree().seq_last
  vim.cmd("silent! redo" .. (count and " " .. count or ""))
  local actual = vim.fn.undotree().seq_last - seq
  if actual > 0 then
    vim.notify("Redo " .. actual .. " change" .. (actual ~= 1 and "s" or ""), vim.log.levels.INFO, {
      title = "Redo",
      timeout = 2000,
    })
  else
    vim.notify("Already at newest change", vim.log.levels.WARN, {
      title = "Redo",
      timeout = 2000,
    })
  end
end

snacks.keymap.set("n", "u", notify_undo, { desc = "Undo with toast" })
snacks.keymap.set("n", "<C-r>", notify_redo, { desc = "Redo with toast" })

return M
