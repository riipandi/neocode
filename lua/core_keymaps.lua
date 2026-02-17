local keymap = vim.keymap.set
local s = { silent = true }
local ns = { noremap = true, silent = true }
local er = { expr = true, replace_keycodes = false }

-- Global function for fzf-lua selection dialogs
-- Used by core_keymaps and other plugins
_G.fzf_select = function(prompt, choices, callback)
  local fzf_lua = require("fzf-lua")
  local height = math.max(7, #choices + 2)
  local width = 35
  fzf_lua.fzf_exec(choices, {
    prompt = prompt .. "> ",
    winopts = {
      height = height,
      width = width,
      row = 0.5,
      col = 0.5,
      border = "rounded",
    },
    actions = {
      ["default"] = function(selected)
        callback(selected[1])
      end,
    },
  })
end

-- Switch focus between explorer and editor
local function switch_focus()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  local current_name = vim.api.nvim_buf_get_name(current_buf)

  local is_nvim_tree = current_name:match("NvimTree")

  if is_nvim_tree then
    -- Currently in explorer, go to previous window
    vim.cmd("wincmd p")
  else
    -- Currently in editor, check if nvim-tree is open
    local nvim_tree_open = false
    pcall(function()
      nvim_tree_open = require("nvim-tree.view").is_visible()
    end)

    if nvim_tree_open then
      -- Find and focus nvim-tree window
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match("NvimTree") then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    else
      vim.cmd("NvimTreeOpen")
    end
  end
end

keymap("n", "<C-e>", switch_focus, { desc = "Switch focus explorer <-> editor" })
keymap("n", "<C-S-e>", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer (Ctrl+Shift+E)" })

-- Key mappings
vim.g.mapleader = " "               -- Set leader key to space
vim.g.maplocalleader = " "          -- Set local leader key (NEW)

-- Normal mode mappings
keymap("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Center screen when jumping
keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Delete without yanking
keymap({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Buffer navigation
keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

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

-- Quick file navigation
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Go to line with Ctrl+G (format: line or line:col)
keymap("n", "<C-g>", function()
  -- Check if there's a valid buffer open
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    vim.cmd('echo "No file open"')
    return
  end

  vim.ui.input({ prompt = "Go to [line:col]: " }, function(input)
    if input and input ~= "" then
      local line, col = input:match("(%d+):(%d+)")
      if line and col then
        vim.cmd(line)
        vim.cmd("normal! " .. col .. "|")
      else
        local num = tonumber(input)
        if num then
          vim.cmd(tostring(num))
        end
      end
    end
  end)
end, { desc = "Go to line or line:col" })

-- Buffer list with Ctrl+B
keymap("n", "<C-b>", "<cmd>Telescope buffers<CR>", { desc = "Show buffer list" })

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

    -- Prevent closing when focused on nvim-tree
    if current_name:match("NvimTree") then
      vim.cmd('echo "Cannot close explorer buffer"')
      return
    end

    local buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local modified = vim.api.nvim_buf_get_option(buf, "modified")

    local is_empty = (buf_name == "" and not modified)

    -- Check if nvim-tree is open
    local nvim_tree_open = false
    pcall(function()
      nvim_tree_open = require("nvim-tree.view").is_visible()
    end)

    -- Count valid buffers (not including nvim-tree)
    local valid_buffers = 0
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) then
        local name = vim.api.nvim_buf_get_name(b)
        if name and name ~= "" and not name:match("NvimTree") then
          valid_buffers = valid_buffers + 1
        end
      end
    end

    if is_empty and nvim_tree_open and valid_buffers <= 1 then
      vim.cmd('echo "Cannot close last buffer when explorer is open"')
      return
    end

    if is_empty then
      vim.cmd('echo "Cannot close empty buffer"')
      return
    end

    local windows = vim.api.nvim_list_wins()
    local is_last_window = #windows <= 1

    local close_action = function()
      local other_bufs = {}
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if b ~= buf and vim.api.nvim_buf_is_valid(b) then
          local name = vim.api.nvim_buf_get_name(b)
          if name and name ~= "" and not name:match("NvimTree") then
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
    end

    if valid_buffers <= 1 then
      vim.notify("Cannot close last buffer", vim.log.levels.WARN)
      return
    end

    if valid_buffers <= 1 then
      vim.cmd('echo "Cannot close last buffer"')
      return
    end

    if modified then
      fzf_select("Save changes?", { "Yes", "No" }, function(choice)
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
    local modified = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "modified") then
        local name = vim.api.nvim_buf_get_name(buf)
        if name ~= "" then
          table.insert(modified, name)
        end
      end
    end

    if #modified > 0 then
      fzf_select("Unsaved files - save?", { "Save all and close", "Don't save and close", "Cancel" }, function(choice)
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
    fzf_select("Quit Neovim?", { "Yes", "No" }, function(choice)
      if choice ~= "Yes" then
        return
      end

      local modified_buffers = {}
      local buffers = vim.api.nvim_list_bufs()

      for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "modified") then
          local name = vim.api.nvim_buf_get_name(buf)
          if name ~= "" then
            table.insert(modified_buffers, { id = buf, name = vim.fs.basename(name) })
          end
        end
      end

      if #modified_buffers > 0 then
        fzf_select("Unsaved buffers - save?", { "Save all and quit", "Don't save and quit", "Cancel" }, function(choice2)
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
