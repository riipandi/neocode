local snacks = require("snacks")

-- Helper function to check if buffer is snacks explorer
local function is_explorer_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local ft = vim.bo[buf].filetype
  return name:match("snacks_explorer") or ft == "snacks_picker_list"
end

-- Key mappings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Search & Navigation
snacks.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })
snacks.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
snacks.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
snacks.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Editing
snacks.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
snacks.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })
snacks.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
snacks.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move lines up/down
snacks.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
snacks.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
snacks.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
snacks.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Window management
snacks.keymap.set("n", "<C-\\>", ":vsplit<CR>", { desc = "Split vertical" })
snacks.keymap.set("n", "<C-S-\\>", ":split<CR>", { desc = "Split horizontal" })
snacks.keymap.set("n", "<C-A-[>", ":wincmd p<CR>", { desc = "Previous window" })
snacks.keymap.set("n", "<C-A-]>", ":wincmd w<CR>", { desc = "Next window" })
snacks.keymap.set("n", "<C-A-=>", ":vertical resize +2<CR>", { desc = "Increase width" })
snacks.keymap.set("n", "<C-A-->", ":vertical resize -2<CR>", { desc = "Decrease width" })
snacks.keymap.set("n", "<C-S-=>", ":resize +2<CR>", { desc = "Increase height" })
snacks.keymap.set("n", "<C-S-->", ":resize -2<CR>", { desc = "Decrease height" })

-- Config & Plugins
snacks.keymap.set("n", "<leader>,", ":e ~/.config/nvim<CR>", { desc = "Edit neovim config" })
snacks.keymap.set("n", "<leader>pu", '<cmd>lua vim.pack.update()<CR>', { desc = "Update plugins" })
snacks.keymap.set("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>', { desc = "Change working directory to current file" })

-- Diagnostics
snacks.keymap.set("n", "<leader>dn", "<cmd>lua vim.diagnostic.jump({count = 1})<CR>", { desc = "Next diagnostic", silent = true })
snacks.keymap.set("n", "<leader>dp", "<cmd>lua vim.diagnostic.jump({count = -1})<CR>", { desc = "Previous diagnostic", silent = true })

-- Buffer management
_G.close_buffer = function()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  local current_name = vim.api.nvim_buf_get_name(current_buf)

  if is_explorer_buffer(current_buf) then
    vim.notify("Cannot close explorer buffer", vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local modified = vim.api.nvim_get_option_value("modified", { buf = buf })

  local is_empty = (buf_name == "" and not modified)

  local valid_buffers = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) then
      local name = vim.api.nvim_buf_get_name(b)
      if name and name ~= "" and not is_explorer_buffer(b) then
        valid_buffers = valid_buffers + 1
      end
    end
  end

  if is_empty then
    vim.notify("Cannot close empty buffer", vim.log.levels.WARN)
    return
  end

  local close_action = function()
    local other_bufs = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if b ~= buf and vim.api.nvim_buf_is_valid(b) then
        local name = vim.api.nvim_buf_get_name(b)
        if name and name ~= "" and not is_explorer_buffer(b) then
          table.insert(other_bufs, b)
        end
      end
    end

    if #other_bufs > 0 then
      vim.api.nvim_set_current_buf(other_bufs[1])
    end

    pcall(function()
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    vim.schedule(function()
      local remaining = 0
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) then
          local name = vim.api.nvim_buf_get_name(b)
          if name and name ~= "" and not is_explorer_buffer(b) then
            remaining = remaining + 1
          end
        end
      end

      if remaining == 0 then
        vim.cmd("enew")
      end
    end)
  end

  if modified then
    ui_select("Save changes?", { "Yes", "No" }, function(choice)
      if choice == "Yes" then
        vim.cmd.write()
      end
      close_action()
    end)
  else
    close_action()
  end
end

snacks.keymap.set("n", "<C-x>", _G.close_buffer, { desc = "Close buffer" })

-- Close all buffers
_G.close_all_buffers = function()
  local valid_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name and name ~= "" and not is_explorer_buffer(buf) then
        table.insert(valid_buffers, buf)
      end
    end
  end

  if #valid_buffers == 0 then
    vim.notify("No buffers to close", vim.log.levels.WARN)
    return
  end

  local modified = {}
  for _, buf in ipairs(valid_buffers) do
    if vim.api.nvim_get_option_value("modified", { buf = buf }) then
      local name = vim.api.nvim_buf_get_name(buf)
      table.insert(modified, name)
    end
  end

  if #modified > 0 then
    ui_select("Unsaved files - save?", { "Save all and close", "Don't save and close", "Cancel" }, function(choice)
      if choice == "Save all and close" then
        vim.cmd("wall")
        vim.cmd("bufdo! bdelete!")
      elseif choice == "Don't save and close" then
        vim.cmd("bufdo! bdelete!")
      end
    end)
  else
    vim.cmd("bufdo! bdelete!")
  end
end

snacks.keymap.set("n", "<C-S-w>", _G.close_all_buffers, { desc = "Close all buffers" })

-- Quit Neovim
_G.quit_neovim = function()
  ui_select("Quit Neovim?", { "Yes", "No" }, function(choice)
    if choice ~= "Yes" then
      return
    end

    local modified_buffers = {}
    local buffers = vim.api.nvim_list_bufs()

    for _, buf in ipairs(buffers) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_option_value("modified", { buf = buf }) then
        local name = vim.api.nvim_buf_get_name(buf)
        if name ~= "" then
          table.insert(modified_buffers, { id = buf, name = vim.fs.basename(name) })
        end
      end
    end

    if #modified_buffers > 0 then
      ui_select("Unsaved buffers - save?", { "Save all and quit", "Don't save and quit", "Cancel" }, function(choice2)
        if choice2 == "Save all and quit" then
          vim.cmd("wall")
          vim.cmd("qa!")
        elseif choice2 == "Don't save and quit" then
          vim.cmd("qa!")
        end
      end)
    else
      vim.cmd("qa!")
    end
  end)
end

snacks.keymap.set("n", "<C-q>", _G.quit_neovim, { desc = "Quit Neovim" })
snacks.keymap.set("n", "<leader>qq", _G.quit_neovim, { desc = "Quit Neovim" })
snacks.keymap.set("n", "<leader>qa", ":qa<CR>", { desc = "Quit all" })
