-- ============================================================================
-- File Explorer Keymaps
-- ============================================================================
-- Custom keymaps for the snacks explorer picker:
--   h/<Left>  : file→parent / dir→collapse-or-jump (visual nav, no CWD change)
--   l/<Right> : toggle expand/collapse
--   y         : yank file content
--   Y         : yank full file path
--   D         : duplicate file or directory
--   <C-d>/]   : jump 2 items down
--   <C-u>/[   : jump 2 items up
--   }         : jump 4 items down
--   {         : jump 4 items up
-- ============================================================================
local snacks = require("snacks")

-- Helper: run an action on the current explorer picker
local function with_explorer(fn)
  local pickers = require("snacks").picker.get({ source = "explorer" })
  local picker = pickers and pickers[1]
  if picker then fn(picker) end
end

-- Toggle folder (expand if collapsed, collapse if expanded)
local function toggle_dir(picker)
  local item = picker:current()
  if item and item.dir then
    local Tree = require("snacks.explorer.tree")
    local Actions = require("snacks.explorer.actions")
    Tree:toggle(item.file)
    Actions.update(picker, { refresh = true })
  end
end

-- Focus parent in tree (visual navigation, no CWD change)
-- File:        collapse parent folder, move cursor to parent
-- Expanded dir: collapse, KEEP CURSOR on that folder
-- Collapsed dir: move cursor to parent
local function collapse_or_up(picker)
  local item = picker:current()
  if not item or not item.file then return end
  local Tree = require("snacks.explorer.tree")
  local Actions = require("snacks.explorer.actions")
  local parent = vim.fs.dirname(item.file)
  if item.dir then
    if item.open then
      -- Expanded folder: collapse it and stay on the same row
      Tree:close(item.file)
      Actions.update(picker, { refresh = true })
    else
      -- Collapsed folder: jump cursor to parent
      Actions.update(picker, { target = parent, refresh = true })
    end
  else
    -- File: collapse parent folder, move cursor to parent
    Actions.update(picker, { target = parent, refresh = true })
  end
end

-- y: yank file content (like :cat)
local function yank_content(picker)
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
end

-- D: duplicate file or directory
local function duplicate(picker)
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
end

-- Override source-specific explorer keys
local explorer_keys = require("snacks.picker.config.sources").explorer.win.list.keys
explorer_keys["h"] = function() with_explorer(collapse_or_up) end
explorer_keys["l"] = function() with_explorer(toggle_dir) end
explorer_keys["<Left>"] = function() with_explorer(collapse_or_up) end
explorer_keys["<Right>"] = function() with_explorer(toggle_dir) end
explorer_keys["k"] = "list_up"
explorer_keys["y"] = function() with_explorer(yank_content) end
explorer_keys["Y"] = "explorer_yank"
explorer_keys["D"] = function() with_explorer(duplicate) end
explorer_keys["j"] = "list_down"

-- Buffer-style jump keys (list window only)
-- Set via FileType autocmd below with vim.schedule to avoid race condition
local s_group = vim.api.nvim_create_augroup("explorer_keys", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = s_group,
  pattern = { "snacks_picker_list", "snacks_picker_input" },
  callback = function(ev)
    local picker
    for _, p in ipairs(require("snacks").picker.get({ bufnr = ev.buf })) do
      if p.opts.source == "explorer" then picker = p; break end
    end
    if not picker then return end
    -- defer so it runs after snacks registers its own keymaps
    vim.schedule(function()
      local function jump(delta) picker.list:move(delta); picker:update() end
      local function refocus() picker:focus() end
      if ev.match == "snacks_picker_list" then
        vim.keymap.set("n", "<C-d>", function() jump(2) end, { buffer = ev.buf, silent = true })
        vim.keymap.set("n", "<C-u>", function() jump(-2) end, { buffer = ev.buf, silent = true })
        vim.keymap.set("n", "]", function() jump(2) end, { buffer = ev.buf, silent = true })
        vim.keymap.set("n", "[", function() jump(-2) end, { buffer = ev.buf, silent = true })
        vim.keymap.set("n", "}", function() jump(4) end, { buffer = ev.buf, silent = true })
        vim.keymap.set("n", "{", function() jump(-4) end, { buffer = ev.buf, silent = true })
        vim.keymap.set("n", "<Esc>", refocus, { buffer = ev.buf, silent = true })
        vim.keymap.set("n", "q", refocus, { buffer = ev.buf, silent = true })
      else  -- input window (search field)
        -- <Esc> clears the search and returns focus to list
        vim.keymap.set({ "n", "i" }, "<Esc>", function() picker.input:set(""); picker:find(); picker:focus() end, { buffer = ev.buf, silent = true })
        vim.keymap.set("n", "q", refocus, { buffer = ev.buf, silent = true })
      end
    end)
  end,
})

-- Migration note: <leader>tm now uses the custom MasonPkg picker (see core_lsp.lua)
-- Old snacks mason picker keymap is removed.

return M
