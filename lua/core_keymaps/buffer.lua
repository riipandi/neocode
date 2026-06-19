-- ============================================================================
-- Buffer Management: <C-x>, <leader>bd/bb/bo, <C-S-w>
-- ============================================================================
-- Smart <C-x>:
--   • multiple listed buffers → close current, load previous (or most recent) one
--   • only listed buffer remaining → close current, create empty buffer
--   • explorer is preserved (it lives in a separate window)
local snacks = require("snacks")
local function smart_close()
  -- Don't close the explorer/picker window via <C-x>
  if (vim.bo.filetype or ""):match("snacks_picker") then
    return
  end

  -- Save prompt for unsaved changes
  local function do_close(force)
    -- Snacks.bufdelete replaces the current buffer with the most-recent
    -- listed buffer (or creates an empty one if none remain). Explorer
    -- is preserved because it lives in a separate window.
    Snacks.bufdelete({ buf = 0, force = force })
  end

  if vim.bo.modified then
    vim.ui.select({ 'Save & Close', 'Close without saving', 'Cancel' }, {
      prompt = 'Buffer has unsaved changes:',
    }, function(choice)
      if choice == 'Save & Close' then
        vim.cmd('w')
        do_close(false)
      elseif choice == 'Close without saving' then
        do_close(true)
      end
    end)
  else
    do_close(false)
  end
end

snacks.keymap.set("n", "<C-x>", smart_close, { desc = 'Close buffer (smart)' })

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
