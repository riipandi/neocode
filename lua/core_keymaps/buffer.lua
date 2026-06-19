-- ============================================================================
-- Buffer Management: <C-x>, <leader>bd/bb/bo, <C-S-w>
-- ============================================================================
-- Smart <C-x> that keeps the file explorer open with a blank buffer
-- when the last editor buffer is closed.
local snacks = require("snacks")

snacks.keymap.set("n", "<C-x>", function()
  local wins = vim.api.nvim_list_wins()

  if #wins > 1 then
    -- Don't close the explorer/picker window via <C-x>
    if (vim.bo.filetype or ""):match("snacks_picker") then
      return
    end

    -- Check if explorer is open as sidebar
    local pickers = require("snacks").picker.get({ source = "explorer" })
    local has_explorer = pickers and #pickers > 0

    if has_explorer then
      -- Delete buffer instead of closing window, preserves layout
      if vim.bo.modified then
        vim.ui.select({ 'Save & Close', 'Close without saving', 'Cancel' }, {
          prompt = 'Buffer has unsaved changes:',
        }, function(choice)
          if choice == 'Save & Close' then
            vim.cmd('w')
            vim.api.nvim_buf_delete(0, { force = false })
          elseif choice == 'Close without saving' then
            vim.api.nvim_buf_delete(0, { force = true })
          end
        end)
      else
        vim.api.nvim_buf_delete(0, { force = false })
      end
      return
    end

    vim.cmd('close')
    return
  end

  if vim.bo.modified then
    vim.ui.select({ 'Save & Close', 'Close without saving', 'Cancel' }, {
      prompt = 'Buffer has unsaved changes:',
    }, function(choice)
      local bufnr = vim.api.nvim_get_current_buf()
      if choice == 'Save & Close' then
        vim.cmd('w')
        vim.api.nvim_buf_delete(bufnr, { force = false })
      elseif choice == 'Close without saving' then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end)
  else
    vim.api.nvim_buf_delete(0, { force = false })
  end
end, { desc = 'Close buffer or split' })

-- Close all buffers with snacks
snacks.keymap.set("n", "<C-S-w>", function()
  Snacks.bufdelete.all()
end, { desc = "Close all buffers" })

-- Delete buffer
snacks.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete buffer" })

-- Buffer picker
snacks.keymap.set("n", "<leader>bb", function()
  Snacks.picker.buffers({
    layout = { preset = "buffers" },
  })
end, { desc = "Buffer picker" })

-- Close other buffers (keep only current)
snacks.keymap.set("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Close other buffers" })

return M
