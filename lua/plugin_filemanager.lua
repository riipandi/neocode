-- ============================================================================
-- File Management Plugins
-- ============================================================================

-- miniharp.nvim: Quick file marks (harpoon-like alternative)
-- UI integration via snacks.picker for consistent look & feel

vim.pack.add({
  { src = 'https://github.com/vieitesss/miniharp.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
})

local snacks = require("snacks")
local miniharp = require('miniharp')

-- =============================================================================
-- Mini harpoon configuration
-- =============================================================================

miniharp.setup({
  autoload = true,
  autosave = true,
  show_on_autoload = false, -- don't open native UI on autoload
})

-- =============================================================================
-- Keymaps
-- =============================================================================

snacks.keymap.set('n', '<leader>ma', miniharp.toggle_file, { desc = 'Toggle file mark' })
snacks.keymap.set('n', '<leader>mc', miniharp.clear,         { desc = 'Clear marks' })
snacks.keymap.set('n', '<C-n>', miniharp.next,              { desc = 'Next mark' })
snacks.keymap.set('n', '<C-S-m>', miniharp.prev,            { desc = 'Previous mark' })

-- =============================================================================
-- Marks picker (replaces miniharp native floating UI)
-- =============================================================================

local marks_mod = require('miniharp.marks')
local ms = require('miniharp.state')
local utils = require('miniharp.utils')
local swap_from = nil

---Kembalikan relatif path + line:col
---@param m MiniharpMark
---@return string
local function mark_label(m)
  return utils.pretty(m.file) .. ":" .. (m.lnum or 1)
end

---Buka picker marks via snacks.picker
local function show_marks_picker()
  if #ms.marks == 0 then
    snacks.notify.info("No marks yet. Use <leader>ma to add one.")
    return
  end

  local current_idx = ms.idx > 0 and ms.idx or nil

  -- Rebuild items every time (marks may have changed)
  local function build_items()
    local items = {}
    for i, m in ipairs(ms.marks) do
      table.insert(items, {
        idx = i,
        file = m.file,
        lnum = m.lnum or 1,
        col = m.col or 0,
        current = i == current_idx,
        text = mark_label(m),
      })
    end
    return items
  end

  local function title()
    local name = swap_from and "Swap mark " .. swap_from .. " →" or "Marks"
    return name .. " (" .. #ms.marks .. ")"
  end

  snacks.picker.pick({
    title = title(),
    items = build_items(),
    format = function(item)
      local icon = item.current and "● " or "  "
      return icon .. item.idx .. ". " .. item.text
    end,
    preview = "file",
    actions = {
      confirm = function(p)
        local sel = p:selected()
        if #sel == 0 then return end
        local item = sel[1]
        marks_mod.jump_to(item.idx)
        p:close()
      end,
    },
    win = {
      input = {
        keys = {
          ["dd"] = function(p)
            local sel = p:selected()
            if #sel == 0 then return end
            local item = sel[1]
            marks_mod.remove_at(item.idx)
            swap_from = nil
            p:close()
            vim.schedule(function() show_marks_picker() end)
          end,
          ["<Tab>"] = function(p)
            local sel = p:selected()
            if #sel == 0 then return end
            local item = sel[1]
            if not swap_from then
              -- First selection: mark for swap
              swap_from = item.idx
              snacks.notify.info("Swap from #" .. item.idx .. ". Tab another mark to complete.")
            else
              -- Second selection: complete swap
              local other = swap_from
              swap_from = nil
              marks_mod.swap(other, item.idx)
              p:close()
              vim.schedule(function() show_marks_picker() end)
            end
          end,
        },
      },
    },
  })
end

snacks.keymap.set('n', '<C-l>', show_marks_picker, { desc = 'List marks' })
