-- ============================================================================
-- Mason Package Picker
-- ============================================================================
-- Main picker logic with category cycling, install/uninstall actions.
-- ============================================================================
local snacks = require("snacks")
local util = require("mason_pkg.util")
local format = require("mason_pkg.format")

local M = {}

-- Track the current picker instance
M._instance = nil

-- Find the index of a category in CATEGORIES
local function find_category_idx(cat_name)
    for i, c in ipairs(util.CATEGORIES) do
        if c == cat_name then return i end
    end
    return #util.CATEGORIES -- default to "All"
end

-- Open the picker (or refresh it with a different category)
-- @param cat_name string|nil (nil = all categories)
function M.open(cat_name)
    if M._instance and not M._instance.closed then
        M._instance:close()
    end

    local items = util.get_items(cat_name)
    if #items == 0 then
        vim.notify("No packages found for this category.", vim.log.levels.WARN, { title = "Mason" })
        return
    end

    local current_name = cat_name or "All Packages"

    M._instance = snacks.picker.pick({
        title = "Mason: " .. current_name .. " (" .. #items .. ")",
        items = items,
        layout = { preset = "default" },
        format = format.format_item,
        preview = format.preview_item,
        actions = {
            -- Cycle to next category
            tab_next = function(p)
                local idx = find_category_idx(cat_name)
                idx = idx % #util.CATEGORIES + 1
                M.open(idx >= #util.CATEGORIES and nil or util.CATEGORIES[idx])
            end,

            -- Cycle to previous category
            tab_prev = function(p)
                local idx = find_category_idx(cat_name) - 1
                if idx < 1 then idx = #util.CATEGORIES - 1 end
                M.open(idx >= 1 and idx < #util.CATEGORIES and util.CATEGORIES[idx] or nil)
            end,

            -- Install selected packages
            install = function(p)
                local sel = p:selected()
                if #sel == 0 then
                    snacks.notify.info("Select packages first (Tab to multi-select).")
                    return
                end
                util.toggle_packages(sel, "install")
                local names = vim.tbl_map(function(i) return i.name end, sel)
                snacks.notify.info("Installing: " .. table.concat(names, ", ") .. ". Check :MasonLog.")
                p:close()
            end,

            -- Uninstall selected packages
            uninstall = function(p)
                local sel = p:selected()
                if #sel == 0 then
                    snacks.notify.info("Select packages first (Tab to multi-select).")
                    return
                end
                util.toggle_packages(sel, "uninstall")
                local names = vim.tbl_map(function(i) return i.name end, sel)
                snacks.notify.info("Uninstalled: " .. table.concat(names, ", "))
                p:close()
            end,

            -- Update Mason registries
            update = function(_p)
                local registry = require("mason-registry")
                pcall(registry.update)
                snacks.notify.info("Mason registries updated.")
            end,

            -- Sub-menu: install/uninstall/details
            confirm = function(p)
                local sel = p:selected()
                if #sel == 0 then return end
                local item = sel[1]
                local choices = item.installed
                    and { "Uninstall", "Details", "Cancel" }
                    or { "Install", "Details", "Cancel" }
                vim.ui.select(choices, {
                    prompt = item.name .. "  [" .. item.cat .. "]",
                }, function(choice)
                    if choice == "Install" then
                        local ok, err = pcall(function() item.pkg:install() end)
                        if ok then
                            snacks.notify.info("Installing " .. item.name .. ". Check :MasonLog.")
                        else
                            vim.notify("Failed: " .. tostring(err), vim.log.levels.ERROR, { title = "Mason" })
                        end
                        p:close()
                    elseif choice == "Uninstall" then
                        pcall(function() item.pkg:uninstall() end)
                        snacks.notify.info("Uninstalled " .. item.name .. ".")
                        p:close()
                    elseif choice == "Details" then
                        local info = {
                            "## " .. item.name, "",
                            "  **Category:** " .. item.cat,
                            "  **Status:** " .. (item.installed and "✅ Installed" or "⬜ Not installed"),
                        }
                        if item.languages ~= "" then
                            table.insert(info, "  **Languages:** " .. item.languages)
                        end
                        if item.description ~= "" then
                            table.insert(info, "", "  " .. item.description)
                        end
                        if item.homepage ~= "" then
                            table.insert(info, "", "  **Homepage:** " .. item.homepage)
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
                    ["<Tab>"]   = { "tab_next", mode = { "n", "i" } },
                    ["<S-Tab>"] = { "tab_prev", mode = { "n", "i" } },
                    ["i"]       = { "install", mode = { "n", "i" } },
                    ["I"]       = { "install", mode = { "n", "i" } },
                    ["x"]       = { "uninstall", mode = { "n", "i" } },
                    ["X"]       = { "uninstall", mode = { "n", "i" } },
                    ["u"]       = { "update", mode = { "n", "i" } },
                    ["U"]       = { "update", mode = { "n", "i" } },
                },
            },
        },
    })
end

return M
