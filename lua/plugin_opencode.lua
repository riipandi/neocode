-- Load required plugins first (snacks must be loaded before opencode)
vim.cmd("packadd! snacks.nvim")
vim.cmd("packadd! opencode.nvim")

-- ============================================================================
-- Snacks configuration (for opencode integration)
-- ============================================================================
local snacks = require("snacks")
snacks.setup({
  input = {},  -- Enhances opencode.ask()
  picker = {
    actions = {
      opencode_send = function(...) return require('opencode').snacks_picker_send(...) end,
    },
    win = {
      input = {
        keys = {
          ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
        },
      },
    },
  },
  terminal = {},  -- Enables the snacks provider for opencode
})

-- ============================================================================
-- OpenCode.nvim configuration
-- ============================================================================
vim.g.opencode_opts = {
  auto_reload = true,
  auto_focus = false,
  command = "opencode",
  win = {
    position = "right",
    width = 0.4,
  },
  provider = {
    enabled = "snacks",
    snacks = {},
  },
}

-- ============================================================================
-- OpenCode keymaps
-- ============================================================================

-- Toggle opencode (your custom keymap)
vim.keymap.set("n", "<C-S-l>", function() require("opencode").toggle() end, { desc = "Toggle OpenCode (Ctrl+Shift+L)" })

-- Ask and select (your custom keymaps with <leader> prefix)
vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "OpenCode: Ask about this" })
vim.keymap.set({ "n", "x" }, "<leader>os", function() require("opencode").select() end, { desc = "OpenCode: Select prompt/command" })
vim.keymap.set("n", "<leader>oc", function() require("opencode").command() end, { desc = "OpenCode: Command" })

-- Session controls
vim.keymap.set("n", "<leader>on", function() require("opencode").command("session.new") end, { desc = "OpenCode: New session" })
vim.keymap.set("n", "<leader>oi", function() require("opencode").command("session.interrupt") end, { desc = "OpenCode: Interrupt session" })
vim.keymap.set("n", "<leader>oA", function() require("opencode").command("agent.cycle") end, { desc = "OpenCode: Cycle agent" })

-- ============================================================================
-- Operator keymaps (add range/line to opencode)
-- ============================================================================
vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end, { desc = "Add range to opencode", expr = true })
vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

-- ============================================================================
-- Scroll opencode
-- ============================================================================
vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end, { desc = "Scroll opencode up" })
vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })
