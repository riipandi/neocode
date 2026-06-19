-- ============================================================================
-- Mason Pkg: Kelola Mason packages via snacks.picker.select
-- ============================================================================
-- Tanpa custom source/format/preview — hanya nested select calls.
-- Ini menghindari error dari snacks.picker.pick() dengan raw items.
-- ============================================================================

local registry = require("mason-registry")

--- Kategorikan satu package Mason berdasarkan spec.categories[]
--- @param cats string[]|nil
--- @return string
local function get_category(cats)
  if not cats then
    return "Other"
  end
  for _, c in ipairs(cats) do
    if c == "LSP" then
      return "LSP"
    elseif c == "DAP" then
      return "DAP"
    elseif c == "Formatter" then
      return "Formatter"
    elseif c == "Linter" then
      return "Linter"
    elseif c == "Compiler" then
      return "Compiler"
    elseif c == "Runtime" then
      return "Runtime"
    end
  end
  return "Other"
end

--- Format satu baris item package untuk ditampilkan di select
--- @param name string
--- @param cat string
--- @param installed boolean
--- @return string
local function format_line(name, cat, installed)
  local icon = installed and "✓" or " "
  local cat_tag = "[" .. cat .. "]"
  return icon .. " " .. name .. "  " .. cat_tag
end

--- Ambil daftar packages, filter by category, return sebagai array of string
--- @param filter_cat string|nil
--- @return string[], table<string, table>
local function get_package_list(filter_cat)
  local names = registry.get_all_package_names()
  local lines = {}
  local meta = {} --- @type table<string, {name:string, cat:string, installed:boolean, pkg:any}>

  for _, name in ipairs(names) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and pkg then
      local cat = get_category(pkg.spec.categories)
      if not filter_cat or cat == filter_cat then
        local installed = pkg:is_installed()
        table.insert(lines, format_line(name, cat, installed))
        meta[lines[#lines]] = {
          name = name,
          cat = cat,
          installed = installed,
          pkg = pkg,
        }
      end
    end
  end

  -- Urut: installed first, lalu alfabetis
  table.sort(lines, function(a, b)
    local ma, mb = meta[a], meta[b]
    if ma.installed ~= mb.installed then
      return ma.installed
    end
    return ma.name < mb.name
  end)

  return lines, meta
end

--- Tampilkan daftar package via snacks.picker.select, lalu aksi
--- @param filter_cat string|nil
local function open_selector(filter_cat)
  local lines, meta = get_package_list(filter_cat)

  -- vim.ui.select is already backed by snacks.picker (ui_select = true)

  local title = filter_cat and ("Mason: " .. filter_cat) or "Mason: All Packages"

  vim.ui.select(lines, {
    prompt = title .. " (" .. #lines .. " packages)",
    format_item = function(line)
      return line
    end,
  }, function(line)
    if not line then
      return
    end

    local m = meta[line]
    if not m then
      return
    end

    local pkg, name = m.pkg, m.name
    local actions = m.installed and { "Uninstall", "Details", "Cancel" } or { "Install", "Details", "Cancel" }

    vim.ui.select(actions, {
      prompt = name .. "  [" .. m.cat .. "]",
      format_item = function(a)
        return a
      end,
    }, function(action)
      if action == "Install" then
        local ok_install, err = pcall(function()
          pkg:install()
        end)
        if ok_install then
          vim.notify('Installing ' .. name .. '. Check :MasonLog.', vim.log.levels.INFO, { title = "Mason" })
        else
          vim.notify('Failed: ' .. tostring(err), vim.log.levels.ERROR, { title = "Mason" })
        end
      elseif action == "Uninstall" then
        pcall(function()
          pkg:uninstall()
        end)
        vim.notify('Uninstalled ' .. name .. '.', vim.log.levels.INFO, { title = "Mason" })
      elseif action == "Details" then
        local info = {
          (m.installed and "✅" or "⬜") .. " " .. name,
          "",
          "  Category:    " .. m.cat,
          "  Status:     " .. (m.installed and "Installed" or "Not installed"),
        }
        local langs = vim.tbl_keys(pkg.spec.languages or {})
        if #langs > 0 then
          table.insert(info, "  Languages:  " .. table.concat(langs, ", "))
        end
        if pkg.spec.description and pkg.spec.description ~= "" then
          table.insert(info, "")
          table.insert(info, "  Description: " .. pkg.spec.description)
        end
        if pkg.spec.homepage and pkg.spec.homepage ~= "" then
          table.insert(info, "")
          table.insert(info, "  Homepage:   " .. pkg.spec.homepage)
        end
        vim.notify(table.concat(info, "\n"), vim.log.levels.INFO, {
          title = "Mason: " .. name,
          timeout = 8000,
        })
      end
    end)
  end)
end

-- ============================================================================
-- User Commands
-- ============================================================================

vim.api.nvim_create_user_command("MasonPkg", function(opts)
  local raw = opts.args or ""
  -- Normalize "all" (any case) to nil (no filter)
  local filter = raw ~= "" and raw or nil
  if filter and filter:lower() == "all" then
    filter = nil
  end
  if filter then
    open_selector(filter)
    return
  end

  -- Tanpa argumen: pilih kategori dulu
  local categories = { "LSP", "Formatter", "Linter", "DAP", "Runtime", "Compiler", "All" }

  -- vim.ui.select is already backed by snacks.picker (ui_select = true)

  vim.ui.select(categories, {
    prompt = "Mason: Select category",
    format_item = function(c)
      return c
    end,
  }, function(choice)
    if choice then
      open_selector(choice == "All" and nil or choice)
    end
  end)
end, {
  desc = "Browse and manage Mason packages",
  nargs = "?",
  complete = function()
    return { "LSP", "Formatter", "Linter", "DAP", "Runtime", "Compiler", "All" }
  end,
})

-- ============================================================================
-- Keymaps
-- ============================================================================
local snacks = require("snacks")
snacks.keymap.set("n", "<leader>tm", function()
  vim.cmd("MasonPkg")
end, { desc = "Mason: manage packages" })
