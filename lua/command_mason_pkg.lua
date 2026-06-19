-- ============================================================================
-- Mason Pkg: GUI untuk mengelola Mason packages via snacks.picker
-- ============================================================================
-- Menggunakan plugin yang sudah ada:
--   - mason-registry    → listing, install, uninstall packages
--   - snacks.picker     → UI picker dengan preview
--   - snacks.notifier   → notifikasi hasil
--   - noice.nvim        → command-line UI (jika ada)
-- ============================================================================

local registry = require("mason-registry")
local snacks = require("snacks")

--- @class MasonPkgItem
--- @field name string
--- @field category string
--- @field description string
--- @field installed boolean
--- @field languages string[]
--- @field homepage string
--- @field text string

--- Ambil package Mason yang akan ditampilkan
--- @param filter_cat string|nil
--- @return MasonPkgItem[]
local function get_items(filter_cat)
  local names = registry.get_all_package_names()
  local items = {}

  for _, name in ipairs(names) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and pkg then
      local cats = pkg.spec.categories or {}
      local cat = "Other"
      for _, c in ipairs(cats) do
        if c == "LSP" then
          cat = "LSP"; break
        elseif c == "DAP" then
          cat = "DAP"; break
        elseif c == "Formatter" then
          cat = "Formatter"; break
        elseif c == "Linter" then
          cat = "Linter"; break
        elseif c == "Compiler" then
          cat = "Compiler"; break
        elseif c == "Runtime" then
          cat = "Runtime"; break
        end
      end

      if filter_cat and cat ~= filter_cat then
        goto continue
      end

      local installed = pkg:is_installed()
      local langs = vim.tbl_keys(pkg.spec.languages or {})
      local desc = (pkg.spec.description or ""):gsub("%s+", " "):sub(1, 120)

      table.insert(items, {
        name = name,
        category = cat,
        description = desc,
        installed = installed,
        languages = langs,
        homepage = pkg.spec.homepage or "",
        text = ("%s [%s] %s"):format(
          installed and "✓" or " ",
          cat,
          name
        ),
      })
    end
    ::continue::
  end

  -- Urutkan: installed first, lalu alfabetis
  table.sort(items, function(a, b)
    if a.installed ~= b.installed then
      return a.installed
    end
    return a.name < b.name
  end)

  return items
end

--- Preview handler: tampilkan detail package
--- @param ctx snacks.picker.preview.ctx
local function preview_pkg(ctx)
  local item = ctx.item
  if not item then
    return ""
  end

  local lines = {}
  table.insert(lines, "# " .. item.name)
  table.insert(lines, "")
  table.insert(lines, "**Category:** " .. item.category)
  table.insert(lines, "**Status:** " .. (item.installed and "✅ Installed" or "⬜ Not installed"))
  if item.languages and #item.languages > 0 then
    table.insert(lines, "**Languages:** " .. table.concat(item.languages, ", "))
  end
  if item.description and item.description ~= "" then
    table.insert(lines, "")
    table.insert(lines, item.description)
  end
  if item.homepage and item.homepage ~= "" then
    table.insert(lines, "")
    table.insert(lines, "**Homepage:** " .. item.homepage)
  end

  return table.concat(lines, "\n")
end

--- Format handler untuk tampilan list
--- @param item MasonPkgItem
local function format_pkg(item)
  local icon = item.installed and "✓" or " "
  return ("%s %s  [%s]"):format(icon, item.name, item.category)
end

--- Install/uninstall package
--- @param items MasonPkgItem[]
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

--- Tampilkan picker untuk Mason packages
--- @param filter string|nil
local function open_picker(filter)
  local all_items = get_items(filter)
  local title = filter and ("Mason: " .. filter) or "Mason: All Packages"

  local picker = snacks.picker.pick({
    title = title,
    items = all_items,
    format = format_pkg,
    preview = preview_pkg,
    actions = {
      confirm = function(p)
        local item = p:selected()[1]
        if not item then return end
        local choices = item.installed and { "Uninstall", "Cancel" } or { "Install", "Cancel" }
        snacks.picker.select(choices, {
          prompt = "Package: " .. item.name,
          layout = { preset = "select" },
        }, function(choice)
          if choice == "Install" then
            toggle_packages({ item }, "install")
            snacks.notify.info("Installing " .. item.name .. ". Check :MasonLog for progress.")
            p:close()
          elseif choice == "Uninstall" then
            toggle_packages({ item }, "uninstall")
            snacks.notify.info("Uninstalled " .. item.name .. ".")
            p:close()
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
        },
      },
    },
  })
end

-- ============================================================================
-- User Commands
-- ============================================================================

vim.api.nvim_create_user_command("MasonPkg", function(opts)
  local filters = { "LSP", "Formatter", "Linter", "DAP", "Runtime", "Compiler", "All" }
  local filter = opts.args
  if filter and filter ~= "" then
    open_picker(filter)
    return
  end

  -- Tanpa argumen: pilih kategori dulu
  snacks.picker.select(filters, {
    prompt = "Mason: Select category",
    layout = { preset = "select" },
  }, function(choice)
    if choice then
      open_picker(choice == "All" and nil or choice)
    end
  end)
end, {
  desc = "Browse and manage Mason packages",
  nargs = "?",
  complete = function()
    return { "LSP", "Formatter", "Linter", "DAP", "Runtime", "Compiler", "All" }
  end,
})
