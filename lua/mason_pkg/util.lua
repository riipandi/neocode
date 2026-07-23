-- ============================================================================
-- Mason Package Utilities
-- ============================================================================
-- Helpers for categorizing and listing Mason packages.
-- ============================================================================
local registry = require("mason-registry")

local M = {}

-- Package categories in display order
M.CATEGORIES = { "LSP", "Formatter", "Linter", "DAP", "Runtime", "Compiler", "All" }

-- Determine category from spec.categories array
function M.get_category(cats)
    if not cats then return "Other" end
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

-- Build list of items for the picker, optionally filtered by category
-- @param filter_cat string|nil (nil = all categories)
function M.get_items(filter_cat)
    local names = registry.get_all_package_names()
    local items = {}

    for _, name in ipairs(names) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and pkg then
            local cat = M.get_category(pkg.spec.categories)
            if not filter_cat or cat == filter_cat then
                local installed = pkg:is_installed()
                local langs = vim.tbl_keys(pkg.spec.languages or {})
                local lang_str = #langs > 0 and table.concat(langs, ", ") or ""

                table.insert(items, {
                    name = name,
                    cat = cat,
                    installed = installed,
                    languages = lang_str,
                    pkg = pkg,
                    description = (pkg.spec.description or ""):gsub("%s+", " "):sub(1, 120),
                    homepage = pkg.spec.homepage or "",
                    text = name .. " " .. cat .. " " .. lang_str,
                })
            end
        end
    end

    -- Sort: installed first, then alphabetical
    table.sort(items, function(a, b)
        if a.installed ~= b.installed then return a.installed end
        return a.name < b.name
    end)

    return items
end

-- Install or uninstall a list of packages
function M.toggle_packages(items, action)
    for _, item in ipairs(items) do
        local ok, pkg = pcall(registry.get_package, item.name)
        if ok and pkg then
            if action == "install" then pkg:install() else pkg:uninstall() end
        end
    end
end

return M
