-- ============================================================================
-- Core Keymaps
-- ============================================================================

local snacks = require("snacks")

-- ============================================================================
-- Leader Key
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- Escape: Close floating windows or clear search
-- ============================================================================

vim.keymap.set({ "n", "t" }, "<Esc>", function()
  -- Don't close if in terminal buffer
  if vim.bo.buftype == "terminal" then
    vim.cmd('close')
    return
  end
  -- Close floating windows
  local conf = vim.api.nvim_win_get_config(0)
  if conf.relative ~= "" then
    vim.cmd('close')
    return
  end
  -- Otherwise, clear search highlights
  vim.cmd('nohlsearch')
end, { silent = true })

-- ============================================================================
-- Search & Navigation
-- ============================================================================

snacks.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })
snacks.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
snacks.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })


-- ============================================================================
-- Editing
-- ============================================================================

snacks.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
snacks.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })
snacks.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })

-- ============================================================================
-- Undo/Redo with toast notification
-- ============================================================================

local function notify_undo()
    local count = vim.v.count > 0 and vim.v.count or nil
    local seq = vim.fn.undotree().seq_last
    vim.cmd("silent! undo" .. (count and " " .. count or ""))
    local actual = seq - vim.fn.undotree().seq_last
    if actual > 0 then
        vim.notify("Undo " .. actual .. " change" .. (actual ~= 1 and "s" or ""), vim.log.levels.INFO, {
            title = "Undo",
            timeout = 2000,
        })
    else
        vim.notify("Already at oldest change", vim.log.levels.WARN, {
            title = "Undo",
            timeout = 2000,
        })
    end
end

local function notify_redo()
    local count = vim.v.count > 0 and vim.v.count or nil
    local seq = vim.fn.undotree().seq_last
    vim.cmd("silent! redo" .. (count and " " .. count or ""))
    local actual = vim.fn.undotree().seq_last - seq
    if actual > 0 then
        vim.notify("Redo " .. actual .. " change" .. (actual ~= 1 and "s" or ""), vim.log.levels.INFO, {
            title = "Redo",
            timeout = 2000,
        })
    else
        vim.notify("Already at newest change", vim.log.levels.WARN, {
            title = "Redo",
            timeout = 2000,
        })
    end
end

snacks.keymap.set("n", "u", notify_undo, { desc = "Undo with toast" })
snacks.keymap.set("n", "<C-r>", notify_redo, { desc = "Redo with toast" })

-- Move lines up/down with Alt+J/K
snacks.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
snacks.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
snacks.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
snacks.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ============================================================================
-- Window Management
-- ============================================================================

snacks.keymap.set("n", "<C-\\>", ":vsplit<CR>", { desc = "Split vertical" })
snacks.keymap.set("n", "<C-S-\\>", ":split<CR>", { desc = "Split horizontal" })
snacks.keymap.set("n", "<C-A-[>", ":wincmd p<CR>", { desc = "Previous window" })
snacks.keymap.set("n", "<C-A-]>", ":wincmd w<CR>", { desc = "Next window" })
snacks.keymap.set("n", "<C-A-=>", ":vertical resize +2<CR>", { desc = "Increase width" })
snacks.keymap.set("n", "<C-A-->", ":vertical resize -2<CR>", { desc = "Decrease width" })
snacks.keymap.set("n", "<C-S-=>", ":resize +2<CR>", { desc = "Increase height" })
snacks.keymap.set("n", "<C-S-->", ":resize -2<CR>", { desc = "Decrease height" })

-- ============================================================================
-- Config & Plugins
-- ============================================================================

snacks.keymap.set("n", "<leader>,", ":e ~/.config/nvim<CR>", { desc = "Edit neovim config" })
snacks.keymap.set("n", "<leader>pu", '<cmd>lua vim.pack.update()<CR>', { desc = "Update plugins" })
snacks.keymap.set("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>', { desc = "Change working directory to current file" })

-- ============================================================================
-- Go Tools
-- ============================================================================

-- Run gotestsum for current file
snacks.keymap.set("n", "<leader>gt", function()
  local filename = vim.fn.expand('%:t')
  local cmd = string.format('gotestsum --format=standard-verbose -- -run . -count=1 %s', vim.fn.shellescape(filename))
  require('snacks').terminal(cmd, { title = 'gotestsum' })
end, { desc = 'Run gotestsum for current file' })

-- Run gotestsum for all tests
snacks.keymap.set("n", "<leader>gT", function()
  require('snacks').terminal('gotestsum --format=standard-verbose -- ./...', { title = 'gotestsum all' })
end, { desc = 'Run gotestsum for all tests' })

-- ============================================================================
-- Scratch Buffers
-- ============================================================================

-- Toggle scratch buffer for quick testing/notes
snacks.keymap.set("n", "<leader>.", function()
  Snacks.scratch()
end, { desc = "Toggle scratch buffer" })

-- Select from existing scratch buffers
snacks.keymap.set("n", "<leader>S", function()
  Snacks.scratch.select()
end, { desc = "Select scratch buffer" })

-- ============================================================================
-- Buffer Management
-- ============================================================================

-- Close current buffer (confirm only if unsaved changes)
-- When the file explorer is open, delete buffer instead of closing window
-- to prevent the explorer from taking full width.
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

-- ============================================================================
-- Quit (with smart confirmation dialog)
-- ============================================================================

local function confirm_quit()
  -- If cursor is in the file explorer, switch to main editor first
  local buf_name = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local was_in_explorer = buf_name:match("snacks_explorer") or filetype == "snacks_picker_list"
  local prev_win = was_in_explorer and vim.api.nvim_get_current_win() or nil
  if was_in_explorer then
    vim.cmd("wincmd p")
  end

  -- Helper to restore cursor position if quitting is cancelled
  local function restore()
    if prev_win and vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_set_current_win(prev_win)
    end
  end

  -- Check if any buffer has unsaved changes
  local has_unsaved = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].modified then
      has_unsaved = true
      break
    end
  end

  if has_unsaved then
    -- Show options: Save & Quit, Quit Without Saving, Cancel
    vim.ui.select({ 'Save & Quit', 'Quit without saving', 'Cancel' }, {
      prompt = 'You have unsaved buffers:',
    }, function(choice)
      if choice == 'Save & Quit' then
        vim.cmd('wa')
        vim.cmd('qa')
      elseif choice == 'Quit without saving' then
        vim.cmd('qa!')
      else
        restore()
      end
    end)
  else
    -- No unsaved changes: simple Yes/No
    vim.ui.select({ 'Yes', 'No' }, {
      prompt = 'Quit Neovim?',
    }, function(choice)
      if choice == 'Yes' then
        vim.cmd('qa')
      else
        restore()
      end
    end)
  end
end
snacks.keymap.set("n", "<C-q>", confirm_quit, { desc = 'Quit all' })
snacks.keymap.set("n", "<A-q>", confirm_quit, { desc = 'Quit all' })
snacks.keymap.set("n", "<leader>q", confirm_quit, { desc = 'Quit all' })
snacks.keymap.set("n", "<leader>qq", confirm_quit, { desc = 'Quit all' })

-- Override <C-q> in picker/explorer buffers to call confirm_quit instead of qflist
local picker_config = require("snacks").config.picker
picker_config.win = picker_config.win or {}
picker_config.win.list = picker_config.win.list or {}
picker_config.win.input = picker_config.win.input or {}
picker_config.win.list.keys = picker_config.win.list.keys or {}
picker_config.win.input.keys = picker_config.win.input.keys or {}
picker_config.win.list.keys["<C-q>"] = confirm_quit
picker_config.win.list.keys["<A-q>"] = confirm_quit
picker_config.win.input.keys["<C-q>"] = { confirm_quit, mode = { "i", "n" } }
picker_config.win.input.keys["<A-q>"] = { confirm_quit, mode = { "i", "n" } }

-- In picker list windows, `e` moves focus to the editor window
picker_config.win.list.keys["e"] = function(_picker)
  vim.cmd("wincmd p")
end

-- Helper: run an action on the current explorer picker
local function with_explorer(fn)
  local pickers = require("snacks").picker.get({ source = "explorer" })
  local picker = pickers and pickers[1]
  if picker then fn(picker) end
end
-- `l`/`<Right>` → toggle folder (expand if collapsed, collapse if expanded)
local function toggle_dir(picker)
  local item = picker:current()
  if item and item.dir then
    local Tree = require("snacks.explorer.tree")
    local Actions = require("snacks.explorer.actions")
    Tree:toggle(item.file)
    Actions.update(picker, { refresh = true })
  end
end

-- `h`/`<Left>` → collapse parent for file, or collapse/navigate up for folder
local function collapse_or_up(picker)
  local item = picker:current()
  if not item then return end
  local Tree = require("snacks.explorer.tree")
  local Actions = require("snacks.explorer.actions")
  if not item.dir then
    -- file → collapse parent folder, then move into it
    local parent = vim.fs.dirname(item.file)
    Tree:close(parent)
    picker:set_cwd(parent)
    Actions.update(picker, { refresh = true, target = parent })
    return
  end
  if item.open then
    -- folder (expanded) → collapse
    Tree:close(item.file)
    Actions.update(picker, { refresh = true })
    return
  end
  -- folder (collapsed) → navigate up to parent (but not above original CWD)
  local root_cwd = picker.opts.cwd or vim.fn.getcwd()
  local parent_dir = vim.fs.dirname(picker:dir())
  local function norm(path) return vim.fn.fnamemodify(path, ":p"):gsub("/$", "") end
  local n_root, n_parent = norm(root_cwd), norm(parent_dir)
  if n_parent == n_root then return end
  if n_parent:sub(1, #n_root) ~= n_root then return end
  picker:set_cwd(parent_dir)
  picker:find()
end
-- Shift+Arrow: jump cursor by N items (auto-scroll follows)
local function jump_by(p, delta)
  if not p or not p.list then return end
  p.list:move(delta * 10)
end
local function s_down(p) jump_by(p, 1) end
local function s_up(p) jump_by(p, -1) end
-- Override source-specific explorer keys
local explorer_keys = require("snacks.picker.config.sources").explorer.win.list.keys
-- hjkl navigation
explorer_keys["h"] = function() with_explorer(collapse_or_up) end
explorer_keys["l"] = function() with_explorer(toggle_dir) end
explorer_keys["<Left>"] = function() with_explorer(collapse_or_up) end
explorer_keys["<Right>"] = function() with_explorer(toggle_dir) end
explorer_keys["j"] = "list_down"
explorer_keys["k"] = "list_up"
-- Buffer-style jump: small step (2 items) for sidebars
-- <C-d>/<C-u> like half-page jump, {/} like paragraph jump
local s_group = vim.api.nvim_create_augroup("explorer_scroll_keys", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = s_group,
  pattern = "snacks_picker_list",
  callback = function(ev)
    local picker
    for _, p in ipairs(require("snacks").picker.get({ bufnr = ev.buf })) do
      if p.opts.source == "explorer" then picker = p; break end
    end
    if not picker then return end
    local function jump(delta) picker.list:move(delta); picker:update() end
    vim.keymap.set("n", "<C-d>", function() jump(2) end, { buffer = ev.buf, silent = true })
    vim.keymap.set("n", "<C-u>", function() jump(-2) end, { buffer = ev.buf, silent = true })
    vim.keymap.set("n", "]", function() jump(2) end, { buffer = ev.buf, silent = true })
    vim.keymap.set("n", "[", function() jump(-2) end, { buffer = ev.buf, silent = true })
    vim.keymap.set("n", "}", function() jump(4) end, { buffer = ev.buf, silent = true })
    vim.keymap.set("n", "{", function() jump(-4) end, { buffer = ev.buf, silent = true })
  end,
})

-- y: copy file content, Y: copy full file path
explorer_keys["y"] = function(_, _)
  with_explorer(function(picker)
    local items = picker:selected({ fallback = true })
    if not items or #items == 0 then
      local cur = picker:current()
      if cur then items = { cur } end
    end
    if not items or #items == 0 then return end
    local contents = {}
    for _, it in ipairs(items) do
      local file = Snacks.picker.util.path(it)
      if file and vim.fn.filereadable(file) == 1 then
        local f = io.open(file, "r")
        if f then
          contents[#contents + 1] = f:read("*a")
          f:close()
        end
      end
    end
    if #contents > 0 then
      vim.fn.setreg("+", table.concat(contents, "\n"), "c")
      Snacks.notify.info("Yanked content from " .. #items .. " file(s)")
    end
  end)
end
explorer_keys["Y"] = "explorer_yank"

-- D: duplicate file or directory (D)
explorer_keys["D"] = function(_, _)
  with_explorer(function(picker)
    local item = picker:current()
    if not item then
      Snacks.notify.warn("Nothing selected")
      return
    end
    local src = Snacks.picker.util.path(item)
    if not src then return end
    local is_dir = vim.fn.isdirectory(src) == 1
    local parent = vim.fs.dirname(src)
    local default_name = vim.fn.fnamemodify(src, ":t")
    local prompt = is_dir and "Duplicate dir as: " or "Duplicate as: "
    Snacks.input({ prompt = prompt, default = default_name }, function(value)
      if not value or value == "" then return end
      local dst = parent .. "/" .. value
      if vim.uv.fs_stat(dst) then
        Snacks.notify.warn("File already exists: " .. dst)
        return
      end
      Snacks.picker.util.copy_path(src, dst)
      local Tree = require("snacks.explorer.tree")
      Tree:refresh(parent)
      require("snacks.explorer.actions").update(picker, { target = dst })
    end)
  end)
end
-- Navigation keys for all picker list windows (fallback when source has no mapping)
picker_config.win.list.keys["j"] = "list_down"
picker_config.win.list.keys["k"] = "list_up"
picker_config.win.list.keys["<S-Down>"] = s_down
picker_config.win.list.keys["<S-Up>"] = s_up
-- ============================================================================
-- Tools
-- ============================================================================

-- Terminal
snacks.keymap.set("n", "<leader>tt", function()
  Snacks.terminal(vim.o.shell, {
    lazy = false,
  })
end, { desc = "Toggle terminal" })


-- Resource Monitor (mactop on Mac, btop on Linux)
-- Install: brew install mactop (Mac) or brew install btop (cross-platform)
snacks.keymap.set("n", "<leader>tr", function()
  Snacks.terminal("mactop", {
    lazy = false,
    title = "Resource Monitor",
  })
end, { desc = "Resource monitor" })

-- File Explorer
snacks.keymap.set("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Toggle file explorer" })
snacks.keymap.set("n", "<A-e>", function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local in_explorer = buf_name:match("snacks_explorer") or filetype == "snacks_picker_list"

  if in_explorer then
    -- Kursor di explorer → hide/tutup explorer
    local pickers = Snacks.picker.get({ source = "explorer" })
    if pickers and #pickers > 0 then
      pickers[1]:close()
    end
    return
  end

  -- Focus explorer if open, otherwise open it
  local pickers = Snacks.picker.get({ source = "explorer" })
  if pickers and #pickers > 0 then
    pickers[1]:focus()
  else
    Snacks.explorer()
  end
end, { desc = "File explorer: close/focus (<A-e>)" })

-- File Picker (now handled by fff.nvim, see plugin_fff.lua)

-- ============================================================================
-- Cmdline <CR>: toast on search failure or command error
-- ============================================================================
--
-- Intercept <CR> in cmdline mode. For / and ? searches: prevent native
-- E486 `Pattern not found` (avoids the annoying hit-enter prompt) and show
-- a toast instead. For : commands: execute via vim.cmd() and show command
-- errors as toast, avoiding the native bottom-of-terminal message.

vim.keymap.set("c", "<CR>", function()
    local cmdtype = vim.fn.getcmdtype()
    local cmdline = vim.fn.getcmdline()

    if (cmdtype == "/" or cmdtype == "?") and cmdline ~= "" then
        -- Add to search history so <Up> works for next search
        vim.fn.histadd("search", cmdline)
        vim.fn.setreg("/", cmdline)

        -- Cancel cmdline (prevent native search from executing)
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<C-c>", true, false, true),
            "n", false
        )

        -- Execute search ourselves
        local dir = cmdtype == "?" and "b" or ""
        local ok, found = pcall(vim.fn.search, cmdline, "w" .. dir)

        if not ok then
            vim.notify("Search error: " .. tostring(found), vim.log.levels.ERROR, {
                title = "Search",
                timeout = 3000,
            })
        elseif found == 0 then
            vim.notify("Pattern not found: " .. cmdline, vim.log.levels.WARN, {
                title = "Search",
                timeout = 2500,
            })
        end

        return
    end

    if cmdtype == ":" and cmdline ~= "" then
        -- Cancel native cmdline so our vim.cmd() takes over
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<C-c>", true, false, true),
            "n", false
        )

        -- Execute command and catch errors as toast
        local ok, err = pcall(vim.cmd, cmdline)
        if not ok then
            local msg = tostring(err)
            -- Strip VimL error prefix (e.g. "Vim:E492:")
            msg = msg:gsub(".-E%d+:", ""):gsub("[\r\n]", ""):gsub("^%s+", "")
            if msg == "" then
                msg = tostring(err):gsub("[\r\n]", "")
            end
            vim.notify(msg, vim.log.levels.ERROR, {
                title = "Cmdline",
                timeout = 3000,
            })
        end

        return
    end

    -- Default: feed Enter through for non-search, non-: commands (e.g. =, @)
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<CR>", true, false, true),
        "n", false
    )
end, { desc = "Cmdline Enter with toast on error" })
