-- ============================================================================
-- Command Palette & Command History
-- Replaces native cmdline with snacks picker
-- ============================================================================

local snacks = require("snacks")

-- Custom action: execute Vim command directly
local function execute_cmd(picker, item)
  local cmd = item and item.cmd
  if cmd and cmd ~= "" then
    picker:close()
    vim.defer_fn(function()
      local ok, err = pcall(vim.cmd, cmd)
      if not ok then
        vim.notify("Error executing command: " .. err, vim.log.levels.ERROR)
      end
    end, 20)
  end
end

-- ============================================================================
-- Keymaps
-- ============================================================================

-- Command palette: fuzzy search all Vim commands
snacks.keymap.set("n", "<C-S-p>", function()
  snacks.picker.commands({
    layout = { preset = "commands" },
    jump = false,
    actions = {
      confirm = execute_cmd,
    },
  })
end, { desc = "Command palette" })

-- Command history: view and rerun previous commands
snacks.keymap.set("n", "<leader>;", function()
  snacks.picker.history({
    name = "cmd",
    layout = { preset = "cmd_history" },
    jump = false,
    actions = {
      confirm = execute_cmd,
    },
  })
end, { desc = "Command history" })
