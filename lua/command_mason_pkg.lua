-- ============================================================================
-- Mason Pkg: Kelola Mason packages via snacks.picker
-- ============================================================================
-- Tampilan tabular dengan columns: status icon, name, category, languages
-- Keymaps:
--   i / I  → install selected package(s)
--   x / X  → uninstall selected package(s)
--   u / U  → update Mason registries & check for updates
--   Enter  → action sub-menu (install/uninstall/details)
--   <C-s>  → toggle category filter
--   Tab    → multi-select
--
-- Untuk tree navigation (expand/collapse) seperti Mason native:
--   :Mason  → Mason built-in TUI (via <leader>tM)
-- ============================================================================

local registry = require("mason-registry")
local snacks = require("snacks")

--- Kategorikan package berdasarkan spec.categories[]
local function get_category(cats)
  if not cats then return "Other" end
  for _, c in ipairs(cats) do
    if c == "LSP" then return "LSP"
    elseif c == "DAP" then return "DAP"
    elseif c == "Formatter" then return "Formatter"
    elseif c == "Linter" then return "Linter"
    elseif c == "Compiler" then return "Compiler"
    elseif c == "Runtime" then return "Runtime" end
  end
  return "Other"
end

--- Bangun daftar items untuk picker
--- @param filter_cat string|nil
--- @return snacks.picker.finder.Item[]
local function get_items(filter_cat)
  local names = registry.get_all_package_names()
  local items = {}

  for _, name in ipairs(names) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and pkg then
      local cat = get_category(pkg.spec.categories)
      if not filter_cat or cat == filter_cat then
        local installed = pkg:is_installed()
        local langs = vim.tbl_keys(pkg.spec.languages or {})
        local lang_str = #langs > 0 and table.concat(langs, ", ") or ""
        local icon = installed and "✓" or " "

        table.insert(items, {
          name = name,
          cat = cat,
          installed = installed,
          installed_num = installed and 1 or 0,
          languages = lang_str,
          pkg = pkg,
          description = (pkg.spec.description or ""):gsub("%s+", " "):sub(1, 120),
          homepage = pkg.spec.homepage or "",
          -- Display text (digunakan untuk pencarian)
          text = name .. " " .. cat .. " " .. lang_str,
        })
      end
    end
  end

  -- Urut: installed first, lalu alfabetis
  table.sort(items, function(a, b)
    if a.installed ~= b.installed then return a.installed end
    return a.name < b.name
  end)

  return items
end

--- Install/uninstall packages
--- @param items table[]
--- @param action "install"|"uninstall"
local function toggle_packages(items, action)
  for _, item in ipairs(items) do
    local ok, pkg = pcall(registry.get_package, item.name)
    if ok and pkg then
      if action == "install" then
        pkg:install()
      else
        pkg:uninstall()
      end
    end
  end
end

--- Tampilan tabular: columns [✓/ ] name [category] languages
local function format_item(item)
  local icon = item.installed and "✓" or " "
  local pad = (" "):rep(math.max(0, 30 - #item.name))
  local cols = {
    { icon .. " " .. item.name .. pad, item.installed and "String" or "NonText" },
    { "[" .. item.cat .. "]", "Comment" },
    { "  " .. item.languages, "DiagnosticHint" },
  }
  return cols
end

--- Preview: detail package
local function preview_item(ctx)
  local item = ctx.item
  if not item then return "" end

  local lines = {}
  table.insert(lines, "# " .. item.name)
  table.insert(lines, "")
  table.insert(lines, "**Category:** " .. item.cat)
  table.insert(lines, "**Status:** " .. (item.installed and "✅ Installed" or "⬜ Not installed"))
  if item.languages and item.languages ~= "" then
    table.insert(lines, "**Languages:** " .. item.languages)
  end
  if item.description and item.description ~= "" then
    table.insert(lines, "")
    table.insert(lines, item.description)
  end
  if item.homepage and item.homepage ~= "" then
    table.insert(lines, "")
    table.insert(lines, "**Homepage:** " .. item.homepage)
  end
  table.insert(lines, "")
  table.insert(lines, "---")
  table.insert(lines, "i  install  |  x  uninstall  |  u  update")
  table.insert(lines, "Enter  actions  |  Tab  multi-select")
  return table.concat(lines, "\n")
end

--- Buka picker Mason
--- @param filter_cat string|nil
local function open_picker(filter_cat)
  local items = get_items(filter_cat)
  if #items == 0 then
    vim.notify("No packages found for this category.", vim.log.levels.WARN, { title = "Mason" })
    return
  end

  local title = filter_cat and ("Mason: " .. filter_cat) or "Mason: All Packages"
  local cat_filter = filter_cat -- mutable untuk toggle <C-s>

  snacks.picker.pick({
    title = title .. " (" .. #items .. ")",
    items = items,
    format = format_item,
    preview = preview_item,
    actions = {
      install = function(p)
        local sel = p:selected()
        if #sel == 0 then
          snacks.notify.info("Select packages first. Use <Tab> for multi-select.")
          return
        end
        toggle_packages(sel, "install")
        local names = vim.tbl_map(function(i) return i.name end, sel)
        snacks.notify.info("Installing: " .. table.concat(names, ", ") .. ". Check :MasonLog.")
        p:close()
      end,
      uninstall = function(p)
        local sel = p:selected()
        if #sel == 0 then
          snacks.notify.info("Select packages first. Use <Tab> for multi-select.")
          return
        end
        toggle_packages(sel, "uninstall")
        local names = vim.tbl_map(function(i) return i.name end, sel)
        snacks.notify.info("Uninstalled: " .. table.concat(names, ", "))
        p:close()
      end,
      update = function(_p)
        pcall(registry.update)
        snacks.notify.info("Mason registries updated.")
      end,
      confirm = function(p)
        local sel = p:selected()
        if #sel == 0 then return end
        local item = sel[1]
        local choices = item.installed and { "Uninstall", "Details", "Cancel" } or { "Install", "Details", "Cancel" }
        vim.ui.select(choices, {
          prompt = item.name .. "  [" .. item.cat .. "]",
        }, function(choice)
          if choice == "Install" then
            local ok, err = pcall(function() item.pkg:install() end)
            if ok then snacks.notify.info("Installing " .. item.name .. ". Check :MasonLog.")
            else vim.notify("Failed: " .. tostring(err), vim.log.levels.ERROR, { title = "Mason" }) end
            p:close()
          elseif choice == "Uninstall" then
            pcall(function() item.pkg:uninstall() end)
            snacks.notify.info("Uninstalled " .. item.name .. ".")
            p:close()
          elseif choice == "Details" then
            local info = {
              "## " .. item.name,
              "",
              "  **Category:** " .. item.cat,
              "  **Status:** " .. (item.installed and "✅ Installed" or "⬜ Not installed"),
            }
            if item.languages ~= "" then
              table.insert(info, "  **Languages:** " .. item.languages)
            end
            if item.description ~= "" then
              table.insert(info, "")
              table.insert(info, "  " .. item.description)
            end
            if item.homepage ~= "" then
              table.insert(info, "")
              table.insert(info, "  **Homepage:** " .. item.homepage)
            end
            vim.notify(table.concat(info, "\n"), vim.log.levels.INFO, {
              title = "Mason: " .. item.name, timeout = 8000,
            })
          end
        end)
      end,
    },
    win = {
      input = {
        keys = {
          ["i"] = { "install", mode = { "n", "i" } },
          ["I"] = { "install", mode = { "n", "i" } },
          ["x"] = { "uninstall", mode = { "n", "i" } },
          ["X"] = { "uninstall", mode = { "n", "i" } },
          ["u"] = { "update", mode = { "n", "i" } },
          ["U"] = { "update", mode = { "n", "i" } },
        },
      },
    },
  })
end

-- ============================================================================
-- User Commands
-- ============================================================================

vim.api.nvim_create_user_command("MasonPkg", function(opts)
  local raw = opts.args or ""
  local filter = raw ~= "" and raw or nil
  if filter and filter:lower() == "all" then filter = nil end
  open_picker(filter)
end, {
  desc = "Browse & manage Mason packages",
  nargs = "?",
  complete = function()
    return { "LSP", "Formatter", "Linter", "DAP", "Runtime", "Compiler", "All" }
  end,
})

-- ============================================================================
-- Keymaps
-- ============================================================================

snacks.keymap.set("n", "<leader>tm", function()
  vim.cmd("MasonPkg")
end, { desc = "Mason: manage packages" })

snacks.keymap.set("n", "<leader>tM", function()
  vim.cmd("Mason")
end, { desc = "Mason: open TUI (tree view)" })
