-- ============================================================================
-- swpui Integration: Search & Replace TUI
-- ============================================================================

---@class snacks.swpui
---@overload fun(opts?: snacks.swpui.Config): snacks.win
local M = setmetatable({}, {
  __call = function(t, ...)
    return t.open(...)
  end,
})

M.meta = {
  desc = "Open swpui (VSCode-like search & replace TUI) in a floating window",
}

---@class snacks.swpui.Config: snacks.terminal.Opts
---@field args? string[] Custom arguments for swpui
---@field auto_cwd? boolean Automatically detect project root (default: true)
local defaults = {
  auto_cwd = true,
  args = nil,
  win = { style = "swpui" },
}

-- ============================================================================
-- Custom Window Style
-- ============================================================================

Snacks.config.style("swpui", {
  width = 0.9,
  height = 0.9,
  border = "rounded",
  bo = {
    filetype = "snacks_terminal",
  },
  wo = {},
  keys = {
    q = "hide",
  },
})

-- ============================================================================
-- Helper Functions
-- ============================================================================

--- Get git root directory or fallback to cwd
---@return string
local function get_git_root()
  local cwd = vim.fn.getcwd()
  local root = vim.fn.system({ "git", "rev-parse", "--show-toplevel" })
  if vim.v.shell_error == 0 then
    return vim.trim(root)
  end
  return cwd
end

-- ============================================================================
-- Main Functions
-- ============================================================================

--- Open swpui in a floating window
--- Auto-detects git root as project root
---@param opts? snacks.swpui.Config
function M.open(opts)
  opts = Snacks.config.get("swpui", defaults, opts)

  local cmd = { "swp" }
  vim.list_extend(cmd, opts.args or {})

  -- Detect working directory
  local cwd = opts.cwd
  if not cwd then
    cwd = opts.auto_cwd and get_git_root() or vim.fn.getcwd()
  end

  opts.cwd = cwd
  return Snacks.terminal(cmd, opts)
end

-- ============================================================================
-- Health Check
-- ============================================================================

---@private
function M.health()
  local ok = vim.fn.executable("swp") == 1
  Snacks.health[ok and "ok" or "error"]("{swpui} %sinstalled", ok and "" or "not ")

  if ok then
    local handle = io.popen("swp --version 2>&1")
    if handle then
      local version = handle:read("*a")
      handle:close()
      Snacks.health.ok("swpui version: %s", vim.trim(version))
    end
  end
end

return M
