-- ============================================================================
-- Mason Package Format & Preview
-- ============================================================================
-- Formatters for the picker display and preview panel.
-- ============================================================================
local M = {}

-- Format a package item as tabular columns:
--   [icon] [name]                 [category] [languages]
function M.format_item(item)
    local icon = item.installed and "✓" or " "
    local pad = (" "):rep(math.max(0, 30 - #item.name))
    return {
        { icon .. " " .. item.name .. pad, item.installed and "String" or "NonText" },
        { "[" .. item.cat .. "]",          "Comment" },
        { "  " .. item.languages,          "DiagnosticHint" },
    }
end

-- Preview panel: shows package details in markdown
function M.preview_item(ctx)
    local item = ctx.item
    if not item then return end
    local lines = {
        "# " .. item.name, "",
        "**Category:** " .. item.cat,
        "**Status:** " .. (item.installed and "✅ Installed" or "⬜ Not installed"),
    }
    if item.languages and item.languages ~= "" then
        table.insert(lines, "**Languages:** " .. item.languages)
    end
    if item.description and item.description ~= "" then
        vim.list_extend(lines, { "", item.description })
    end
    if item.homepage and item.homepage ~= "" then
        vim.list_extend(lines, { "", "**Homepage:** " .. item.homepage })
    end
    vim.list_extend(lines, {
        "", "---",
        "<Tab> category  |  i install  |  x uninstall  |  u update",
        "Enter actions  |  <C-c> close",
    })
    ctx.preview:reset()
    ctx.preview:set_lines(vim.split(table.concat(lines, "\n"), "\n"))
    ctx.preview:highlight({ ft = "markdown" })
    ctx.preview:set_title(item.name)
end

return M
