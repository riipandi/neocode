-- ============================================================================
-- Mason Pkg: Browse and manage Mason packages via snacks.picker
-- ============================================================================
-- Usage:
--   :MasonPkg                  → show all packages
--   :MasonPkg LSP              → filter to LSP packages
--   :MasonPkg Formatter        → filter to Formatter packages
--   <leader>tm                 → open picker
--   <leader>tM                 → open Mason built-in TUI
--
-- Keymaps (in picker):
--   <Tab> / <S-Tab>  → cycle category (LSP → Formatter → ... → All)
--   i / I            → install selected package(s)
--   x / X            → uninstall selected package(s)
--   u / U            → update Mason registries
--   Enter            → action sub-menu (install/uninstall/details)
-- ============================================================================
local snacks = require("snacks")
local picker = require("mason_pkg.picker")
local util = require("mason_pkg.util")

-- :MasonPkg [category]
vim.api.nvim_create_user_command("MasonPkg", function(opts)
    local raw = opts.args or ""
    local filter = raw ~= "" and raw or nil
    -- "all" is treated as no filter
    if filter and filter:lower() == "all" then filter = nil end
    picker.open(filter)
end, {
    desc = "Browse & manage Mason packages",
    nargs = "?",
    complete = function() return util.CATEGORIES end,
})

-- Keymaps
snacks.keymap.set("n", "<leader>tm", function()
    vim.cmd("MasonPkg")
end, { desc = "Mason: manage packages" })

snacks.keymap.set("n", "<leader>tM", function()
    vim.cmd("Mason")
end, { desc = "Mason: open TUI (tree view)" })
