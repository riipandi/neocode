-- OpenCode.nvim configuration
-- Requires snacks.nvim (loaded in plugin_snacks.lua)

vim.pack.add({
  { src = "https://github.com/nickjvandyke/opencode.nvim" },
})

-- ============================================================================
-- OpenCode.nvim configuration
-- ============================================================================
vim.g.opencode_opts = {
  auto_reload = true,
  auto_focus = false,
  command = "opencode",
  provider = {
    enabled = "snacks",
    snacks = {
      win = {
        position = "right",
        width = math.floor(vim.o.columns * 0.35),
      },
    },
  },
}

-- ============================================================================
-- OpenCode keymaps
-- ============================================================================

-- Toggle opencode
vim.keymap.set("n", "<C-S-l>", function() require("opencode").toggle() end, { desc = "Toggle OpenCode (Ctrl+Shift+L)" })
vim.keymap.set("n", "<leader>oo", function() require("opencode").toggle() end, { desc = "OpenCode: Toggle show/hide" })

-- Focus to opencode panel from editor
vim.keymap.set("n", "<leader>of", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
    local name = vim.api.nvim_buf_get_name(buf)
    if ft == "opencode_terminal" or name:match("opencode") then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  require("opencode").toggle()
end, { desc = "Focus opencode panel" })

-- Set up Escape key to return to editor when in opencode panel
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "opencode_terminal",
  callback = function()
    vim.keymap.set("n", "<Esc>", function()
      vim.cmd("wincmd p")
    end, { buffer = 0, desc = "Return to editor" })
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = 0, desc = "Exit terminal mode" })
  end,
  once = false,
})

-- Ask and select
vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "OpenCode: Ask about this" })
vim.keymap.set({ "n", "x" }, "<leader>os", function() require("opencode").select() end, { desc = "OpenCode: Select prompt/command" })
vim.keymap.set("n", "<leader>oc", function() require("opencode").command() end, { desc = "OpenCode: Command" })

-- Session controls
vim.keymap.set("n", "<leader>on", function() require("opencode").command("session.new") end, { desc = "OpenCode: New session" })
vim.keymap.set("n", "<leader>oi", function() require("opencode").command("session.interrupt") end, { desc = "OpenCode: Interrupt session" })
vim.keymap.set("n", "<leader>ox", function()
  _G.fzf_select("Exit OpenCode?", { "Yes", "No" }, function(choice)
    if choice == "Yes" then
      local notify_orig = vim.notify
      vim.notify = function() end

      pcall(function()
        require("opencode").stop()
      end)

      vim.schedule(function()
        vim.notify = notify_orig
      end)
    end
  end)
end, { desc = "OpenCode: Exit" })
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
