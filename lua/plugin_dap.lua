-- =============================================================================
-- Debug Adapter Protocol (nvim-dap)
-- =============================================================================
-- Currently only Elixir is wired up. The adapter is ElixirLS's debug adapter
-- (elixir-ls-debugger from Mason) because Expert does not provide a DAP yet.
-- The ElixirLS *language* server is not started here; expert owns LSP.
-- Usage: :lua require('dap').continue()  (mapped to <leader>xx below)
-- =============================================================================

vim.pack.add({ { src = "https://github.com/mfussenegger/nvim-dap" } })

-- Mason binaries live here; resolve at use-time so Mason can install later.
local function mason_bin(name)
    return vim.fs.joinpath(vim.fn.stdpath "data", "mason", "bin", name)
end

-- Adapters are configured the first time a debug key is pressed or an Elixir
-- buffer opens, so requiring nvim-dap stays off the startup path.
local configured = false
local function dap()
    local d = require("dap")
    if configured then
        return d
    end
    configured = true
    -- Elixir: ElixirLS debug adapter (mix_task launch type).
    d.adapters.elixir = {
        type = "executable",
        command = mason_bin "elixir-ls-debugger",
        args = {},
    }

    d.configurations.elixir = {
        {
            type = "elixir",
            name = "mix test",
            request = "launch",
            task = "test",
            taskArgs = { "--trace" },
            projectDir = "${workspaceFolder}",
            requireFiles = {
                "test/**/test_helper.exs",
                "test/**/*_test.exs",
            },
        },
        {
            -- Phoenix: do not auto-interpret all modules (Cowboy/Ecto leak memory
            -- when interpreted); only the app's own modules.
            type = "elixir",
            name = "phx.server",
            request = "launch",
            task = "phx.server",
            projectDir = "${workspaceFolder}",
            exitAfterTaskReturns = false,
            debugAutoInterpretAllModules = false,
        },
    }
    return d
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("dap_lazy", { clear = true }),
    pattern = "elixir",
    once = true,
    callback = function()
        dap()
    end,
    desc = "Configure the Elixir debug adapter",
})

-- Minimal keymaps (buffer-local on DAP sessions via filetype hooks would be
-- over-engineering; global leader maps keep it discoverable).
local snacks_ok, snacks = pcall(require, "snacks")
local keymap = snacks_ok and snacks.keymap.set or vim.keymap.set
keymap("n", "<leader>xx", function()
    dap().continue()
end, { desc = "DAP: continue/start" })
keymap("n", "<leader>xb", function()
    dap().toggle_breakpoint()
end, { desc = "DAP: breakpoint" })
keymap("n", "<leader>xo", function()
    dap().step_over()
end, { desc = "DAP: step over" })
keymap("n", "<leader>xi", function()
    dap().step_into()
end, { desc = "DAP: step into" })
keymap("n", "<leader>xO", function()
    dap().step_out()
end, { desc = "DAP: step out" })
keymap("n", "<leader>xq", function()
    dap().terminate()
end, { desc = "DAP: terminate" })
