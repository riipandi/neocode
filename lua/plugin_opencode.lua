vim.pack.add({
  { src = "https://github.com/nickjvandyke/opencode.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
})

-- ============================================================================
-- OpenCode.nvim configuration
-- ============================================================================
require('opencode').setup({
  -- See `https://github.com/NickvanDyke/opencode.nvim/blob/main/lua/opencode/config.lua`
  -- See https://github.com/folke/snacks.nvim/blob/main/docs/win.md for more window options
  -- See https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md for more terminal options
  auto_reload = true,  -- Automatically reload buffers edited by opencode
  auto_focus = false,   -- Focus the opencode window after prompting
  command = "opencode", -- Command to launch opencode
  context = {           -- Context to inject in prompts
    ["@file"] = require("opencode.context").file,
    ["@files"] = require("opencode.context").files,
    ["@cursor"] = require("opencode.context").cursor_position,
    ["@selection"] = require("opencode.context").visual_selection,
    ["@diagnostics"] = require("opencode.context").diagnostics,
  },
  win = {
    position = "right",
  },
})

-- Automatically reload buffers edited by opencode
vim.g.opencode_opts.auto_reload = true

vim.g.opencode_opts = {
  provider = {
    enabled = "snacks",
    snacks = {}
  }
}

-- Recommended/example keymaps for OpenCode.nvim
vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask about this" })
vim.keymap.set({ "n", "x" }, "<leader>o+", function() require("opencode").prompt("@this") end, { desc = "Add this" })
vim.keymap.set({ "n", "x" }, "<leader>os", function() require("opencode").select() end, { desc = "Select prompt" })
vim.keymap.set("n", "<leader>ot", function() require("opencode").toggle() end, { desc = "Toggle embedded" })
vim.keymap.set("n", "<leader>oc", function() require("opencode").command() end, { desc = "Select command" })
vim.keymap.set("n", "<leader>on", function() require("opencode").command("session_new") end, { desc = "New session" })
vim.keymap.set("n", "<leader>oi", function() require("opencode").command("session_interrupt") end, { desc = "Interrupt session" })
vim.keymap.set("n", "<leader>oA", function() require("opencode").command("agent_cycle") end, { desc = "Cycle selected agent" })
vim.keymap.set("n", "<S-C-u>",    function() require("opencode").command("messages_half_page_up") end, { desc = "Messages half page up" })
vim.keymap.set("n", "<S-C-d>",    function() require("opencode").command("messages_half_page_down") end, { desc = "Messages half page down" })
