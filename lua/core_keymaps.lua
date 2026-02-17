local keymap = vim.keymap.set
local s = { silent = true }
local ns = { noremap = true, silent = true }
local er = { expr = true, replace_keycodes = false }



-- Helper function to check if buffer is snacks explorer
local function is_explorer_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local ft = vim.bo[buf].filetype
  return name:match("snacks_explorer") or ft == "snacks_picker_list"
end

-- Key mappings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal mode mappings
keymap("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Center screen when jumping
keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Delete without yanking
keymap({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Splitting
keymap("n", "<C-\\>", ":vsplit<CR>", { desc = "Split vertical" })
keymap("n", "<C-S-\\>", ":split<CR>", { desc = "Split horizontal" })

-- Window navigation (Ctrl+Alt+[/] for next/previous)
keymap("n", "<C-A-[>", ":wincmd p<CR>", { desc = "Previous window" })
keymap("n", "<C-A-]>", ":wincmd w<CR>", { desc = "Next window" })

-- Window resize
keymap("n", "<C-A-=>", ":vertical resize +2<CR>", { desc = "Increase width" })
keymap("n", "<C-A-->", ":vertical resize -2<CR>", { desc = "Decrease width" })
keymap("n", "<C-S-=>", ":resize +2<CR>", { desc = "Increase height" })
keymap("n", "<C-S-->", ":resize -2<CR>", { desc = "Decrease height" })

-- Move lines up/down
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting in visual mode
keymap("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior
keymap("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick config editing
keymap("n", "<leader>,", ":e ~/.config/nvim<CR>", { desc = "Edit neovim config" })

-- Update the plugins easily (using vim.pack)
keymap("n", "<leader>pu", '<cmd>lua vim.pack.update()<CR>')

-- Clear highlights on search when pressing <Esc> in normal mode
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostics keymaps
keymap("n", "<leader>dn", "<cmd>lua vim.diagnostic.jump({count = 1})<CR>", ns)
keymap("n", "<leader>dp", "<cmd>lua vim.diagnostic.jump({count = -1})<CR>", ns)

-- cd current directory of the file
keymap("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>', { desc = "Change working directory to current file" })

-- Buffer management with Ctrl+X (close/delete)
_G.close_buffer = function()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  local current_name = vim.api.nvim_buf_get_name(current_buf)

  -- Prevent closing when focused on snacks explorer
  if is_explorer_buffer(current_buf) then
    vim.notify("Cannot close explorer buffer", vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local modified = vim.api.nvim_get_option_value("modified", { buf = buf })

  local is_empty = (buf_name == "" and not modified)

  -- Count valid buffers (not including snacks explorer)
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

keymap("n", "<C-x>", _G.close_buffer, { desc = "Close buffer (Ctrl+X)" })

-- Close all buffers with confirmation
_G.close_all_buffers = function()
  -- Count valid buffers (excluding snacks explorer)
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

keymap("n", "<C-S-w>", _G.close_all_buffers, { desc = "Close all buffers (Ctrl+Shift+W)" })

-- Quit Neovim with Ctrl+Q (with unsaved changes check)
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

keymap("n", "<C-q>", _G.quit_neovim, { desc = "Quit Neovim (Ctrl+Q)" })
keymap("n", "<leader>qq", _G.quit_neovim, { desc = "Quit Neovim (leader+qq)" })
keymap("n", "<leader>qa", ":qa<CR>", { desc = "Quit all (without checking)" })
