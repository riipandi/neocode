-- Shared geometry and wording for dialogs (confirmations, prompts, command
-- palette, cmdline), so they open in the same place at the same width.
local M = {}

M.width = 60
M.row = 8

-- "Save as: " -> "Save as"; dialog titles carry no trailing colon.
function M.title(prompt)
    return (tostring(prompt):gsub("[%s:]+$", ""))
end

-- <Tab> / <S-Tab> walk the list in single-choice dialogs; snacks' default would
-- tick the item as a multi-selection.
M.keys = {
    ["<Tab>"] = { "list_down", mode = { "i", "n" } },
    ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
}

-- Rounded border whose top edge joins the box above it.
M.joined_border = { "├", "─", "┤", "│", "╯", "─", "╰", "│" }

return M
