-- ============================================================================
-- Command Palette with Categories
-- Replaces native cmdline with snacks picker
-- ============================================================================

local snacks = require("snacks")

-- ============================================================================
-- Command Categories (user customizable)
-- ============================================================================

local command_categories = {
  -- Built-in Neovim commands
  File = {
    "^write", "^read", "^edit", "^saveas", "^update", "^file", "^wn"
  },
  Buffer = {
    "^badd", "^ball", "^balt", "^bdelete", "^bwipeout",
    "^bnext", "^bprevious", "^bfirst", "^blast", "^buffer", "^buffers"
  },
  Window = {
    "^split", "^vsplit", "^close", "^wincmd", "^resize",
    "^win", "^aboveleft", "^belowright", "^topleft", "^botright"
  },
  Tab = {
    "^tabnew", "^tabclose", "^tabmove", "^tabnext", "^tabprevious", "^tabdo"
  },
  Quit = {
    "^quit", "^qall", "^wq", "^qa", "^xit"
  },
  Search = {
    "^global", "^substitute", "^vimgrep", "^grep", "^lgrep", "^hlsearch"
  },
  Quickfix = {
    "^cnext", "^cprev", "^copen", "^cfile", "^cc", "^cold", "^cnewer",
    "^lnext", "^lprev", "^lopen"
  },
  Fold = {
    "^fold", "^zo", "^zc"
  },
  Terminal = {
    "^terminal", "^tab"
  },
  Lua = {
    "^lua", "^luafile", "^source", "^runtime"
  },
  Help = {
    "^help"
  },
  Settings = {
    "^set", "^setlocal", "^options", "^var"
  },
  Syntax = {
    "^syntax", "^highlight", "^hi", "^match"
  },
  -- Plugin commands
  Git = {
    "^Git", "^Gitsigns", "^Neogit", "^Diff"
  },
  LSP = {
    "^Mason", "^Lsp", "^CodeAction", "^Format"
  },
  Tools = {
    "^Telescope", "^Nvim", "^Markdown", "^Hop", "^Harpoon", "^Snacks"
  },
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Get command category based on patterns
local function get_command_category(name)
  for category, patterns in pairs(command_categories) do
    for _, pattern in ipairs(patterns) do
      if name:match(pattern) then
        return category
      end
    end
  end
  return "Other"
end

-- Get all Vim commands (built-in + user + plugin), excluding internal-only
local function get_vim_commands()
  local items = {}
  local commands = vim.api.nvim_get_commands({})
  
  for name, def in pairs(commands) do
    -- Exclude internal-only commands
    local exclude_patterns = {
      "^cabbr?e", "^cunabbr?e",        -- abbreviations
      "^[am]enu", "^unmenu",            -- menus
      "^debug", "^debuggreedy",          -- debug
    }
    
    local is_excluded = false
    for _, pattern in ipairs(exclude_patterns) do
      if name:match(pattern) then
        is_excluded = true
        break
      end
    end
    
    -- Include all other commands with category prefix
    if not is_excluded then
      local category = get_command_category(name)
      table.insert(items, {
        text = name,
        action = ":" .. name,
        category = category,
      })
    end
  end
  
  -- Sort by category first, then by command name
  table.sort(items, function(a, b)
    if a.category ~= b.category then
      return a.category < b.category
    end
    return a.text < b.text
  end)
  
  return items
end

-- ============================================================================
-- Command Palette UI
-- ============================================================================

-- Show command palette with categories
local function show_commands(title, items)
  Snacks.picker({
    title = title,
    layout = {
      preset = "commands",
      preview = false,
    },
    items = items,
    format = function(item, _)
      return {
        { item.category .. ": ", "Special" },
        { item.text, "Function" },
      }
    end,
    confirm = function(picker, item)
      if not item then
        return
      end
      if type(item.action) == "string" then
        if item.action:find("^:") then
          picker:close()
          -- Always open prompt with command
          return picker:norm(function()
            vim.fn.feedkeys(":" .. item.action:sub(2) .. " ", "n")
          end)
        else
          return picker:norm(function()
            local keys = vim.api.nvim_replace_termcodes(item.action, true, true, true)
            vim.api.nvim_input(keys)
          end)
        end
      end
      return picker:norm(function()
        picker:close()
        item.action()
      end)
    end,
  })
end

-- ============================================================================
-- Keymaps
-- ============================================================================

-- Command palette: fuzzy search all Vim commands with categories
snacks.keymap.set("n", "<C-S-p>", function()
  show_commands("Vim Commands", get_vim_commands())
end, { desc = "Command palette" })
