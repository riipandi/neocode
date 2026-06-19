-- ============================================================================
-- File Management Plugins
-- ============================================================================

-- miniharp.nvim: Quick file marks (harpoon-like alternative)
-- List UI via snacks.picker for consistent look & feel

vim.pack.add({
  { src = 'https://github.com/vieitesss/miniharp.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
})

local snacks = require("snacks")
local miniharp = require('miniharp')

-- Setup — native floating window disabled, we use snacks.picker instead
-- =============================================================================

miniharp.setup({
  autoload = true,
  autosave = true,
  show_on_autoload = false,
  notifications = true,
})

-- Route miniharp status messages through vim.notify (intercepted by noice)
-- instead of vim.api.nvim_echo which writes to the command line
local miniharp_notify = require('miniharp.notify')
miniharp_notify.echo = function(chunks, _history, _opts)
  local msg = {}
  for _, c in ipairs(chunks) do
    msg[#msg + 1] = type(c) == "table" and c[1] or tostring(c)
  end
  vim.notify(table.concat(msg), vim.log.levels.INFO, { title = "Marks", timeout = 1500 })
end

-- Close native UI if it ever opens (e.g. stale state from old version)
local ui_close = require('miniharp.ui').close
vim.defer_fn(ui_close, 100)

-- =============================================================================
-- Keymaps
-- =============================================================================

vim.keymap.set('n', '<leader>ma', miniharp.toggle_file, { desc = 'Toggle file mark' })
vim.keymap.set('n', '<leader>mc', miniharp.clear,         { desc = 'Clear marks' })
vim.keymap.set('n', '<C-n>', miniharp.next,              { desc = 'Next mark' })
vim.keymap.set('n', '<C-S-m>', miniharp.prev,            { desc = 'Previous mark' })

-- =============================================================================
-- Marks picker via snacks.picker (replaces native miniharp floating UI)
-- =============================================================================

local marks_mod = require('miniharp.marks')
local ms = require('miniharp.state')
local utils = require('miniharp.utils')
local swap_from = nil

local function show_marks_picker()
  -- Close any stale native UI first
  ui_close()

  if #ms.marks == 0 then
    snacks.notify.info("No marks yet. Use <leader>ma to add one.")
    return
  end

  local current_idx = ms.idx > 0 and ms.idx or nil

  local items = {}
  for i, m in ipairs(ms.marks) do
    local label = utils.pretty(m.file) .. ":" .. (m.lnum or 1)
    table.insert(items, {
      idx = i,
      file = m.file,
      lnum = m.lnum or 1,
      col = m.col or 0,
      current = i == current_idx,
      text = label,
    })
  end

  snacks.picker.pick({
    title = (swap_from and ("Swap from #" .. swap_from) or "Marks") .. " (" .. #ms.marks .. ")",
    items = items,
    format = function(item)
      local icon = item.current and "● " or "  "
      return {
        { icon, item.current and "String" or "Comment" },
        { item.idx .. ". ", "NonText" },
        { item.text, "Function" },
      }
    end,
    actions = {
      confirm = function(p)
        local sel = p:selected()
        if #sel == 0 then return end
        swap_from = nil
        marks_mod.jump_to(sel[1].idx)
        p:close()
      end,
    },
    win = {
      input = {
        keys = {
          ["dd"] = function(p)
            local sel = p:selected()
            if #sel == 0 then return end
            marks_mod.remove_at(sel[1].idx)
            swap_from = nil
            p:close()
            vim.schedule(function() show_marks_picker() end)
          end,
          ["<Tab>"] = function(p)
            local sel = p:selected()
            if #sel == 0 then return end
            local idx = sel[1].idx
            if not swap_from then
              swap_from = idx
              snacks.notify.info("Swap from #" .. idx .. ". Tab another mark to complete.")
            else
              marks_mod.swap(swap_from, idx)
              swap_from = nil
              p:close()
              vim.schedule(function() show_marks_picker() end)
            end
          end,
        },
      },
    },
  })
end

vim.keymap.set('n', '<C-l>', show_marks_picker, { desc = 'List marks' })
