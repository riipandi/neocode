-- ============================================================================
-- Mistral Codestral — AI autocompletion (forked, blink.cmp-only)
-- ============================================================================
-- This file wires up the local mistral-codestral fork to blink.cmp and
-- provides a few Neovim-native integrations:
--   * snacks picker for the auth manager
--   * AI-explain command for the selected blink.cmp item
--   * commit-message generator from `git diff`
--
-- Authentication: set the CODESTRAL_API_KEY environment variable in your
-- shell profile, e.g.:
--   export CODESTRAL_API_KEY="your-key-here"
--
-- The plugin also accepts MISTRAL_API_KEY as a fallback and supports
-- system keyring via :MistralCodestralAuth set.
-- ============================================================================

-- Bail if blink.cmp isn't installed.
local ok_blink, blink = pcall(require, "blink.cmp")
if not ok_blink then
	vim.notify(
		"[mistral-codestral] blink.cmp not available; plugin disabled",
		vim.log.levels.WARN
	)
	return
end

-- Snacks may or may not be available; we feature-check.
local has_snacks, snacks = pcall(require, "snacks")

-- ----------------------------------------------------------------------------
-- 1. Initialize the plugin (config, exclusion cache, virtual text, commands).
-- ----------------------------------------------------------------------------
require("mistral-codestral").setup({
	-- Model & request params
	model = "codestral-latest",
	max_tokens = 256,
	temperature = 0.1,
	timeout = 10000,
	debug = false,

	-- blink.cmp provider options
	max_items = 3, -- one full + first-line variant by default
	min_keyword_length = 0,
	async = false,
	timeout_ms = 2000,

	-- Virtual text (Windsurf-style ghost preview)
	virtual_text = {
		enabled = true,
		manual = false,
		idle_delay = 800,
		min_chars = 3,
		priority = 65535,
		filetypes = {},
		default_filetype_enabled = true,
		key_bindings = {
			accept = "<M-l>",
			accept_word = "<C-Right>",
			accept_line = "<C-Down>",
			next = "<M-]>",
			prev = "<M-[>",
			clear = "<C-c>",
		},
	},

	-- Auth: prefer env (CODESTRAL_API_KEY), then keyring, then explicit config
	auth = {
		methods = { "environment", "keyring", "config" },
		validate_on_startup = false, -- avoid network on startup
	},

	workspace_root = {
		use_lsp = true,
		paths = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" },
	},
})

-- ----------------------------------------------------------------------------
-- 2. Register the provider with blink.cmp using add_source_provider.
-- ----------------------------------------------------------------------------
local function register_provider()
	if type(blink.add_source_provider) ~= "function" then
		vim.notify(
			"[mistral-codestral] blink.cmp is missing add_source_provider; "
				.. "this fork requires blink.cmp v1.6+",
			vim.log.levels.WARN
		)
		return
	end

	-- add_source_provider asserts no duplicate id; guard so the user can
	-- pre-register the provider in their own blink.cmp config.
	local already_registered = false
	do
		local ok, runtime = pcall(require, "blink.cmp.config")
		if
			ok
			and runtime
			and runtime.sources
			and runtime.sources.providers
			and runtime.sources.providers.mistral_codestral
		then
			already_registered = true
		end
	end

	if not already_registered then
		local ok, err = pcall(blink.add_source_provider, "mistral_codestral", {
			name = "Mistral Codestral",
			module = "mistral-codestral.blink",
			-- score_offset at the provider level acts as a baseline boost on
			-- top of any per-item score_offset set in build_items().
			score_offset = 5,
			async = false,
			timeout_ms = 2000,
			opts = {
				max_items = 3,
			},
		})
		if not ok and not tostring(err):match("already exists") then
			vim.notify(
				"[mistral-codestral] failed to register blink.cmp provider: " .. tostring(err),
				vim.log.levels.WARN
			)
		end
	end

	-- Add the provider to the default source list (idempotent).
	local function add_to_default()
		local ok, runtime = pcall(require, "blink.cmp.config")
		if not ok or not runtime or not runtime.sources then
			return
		end
		runtime.sources.default = runtime.sources.default or { "lsp", "path", "snippets", "buffer" }
		local has = false
		for _, src in ipairs(runtime.sources.default) do
			if src == "mistral_codestral" then
				has = true
				break
			end
		end
		if not has then
			table.insert(runtime.sources.default, "mistral_codestral")
		end
	end

	add_to_default()
end

register_provider()

-- ----------------------------------------------------------------------------
-- 3. Override :MistralCodestralAuth to use a snacks picker (if available).
--    Falls back to the built-in vim.fn.confirm prompt otherwise.
-- ----------------------------------------------------------------------------
local function open_auth_picker()
	if not has_snacks or not snacks.picker or not snacks.picker.select then
		-- Fallback: no snacks picker available, show status
		require("mistral-codestral.auth").auth_command({ fargs = { "status" } })
		return
	end

	-- Each entry: { label = "<display text>", sub = "<auth subcommand>" }
	-- The label is the string shown in the picker.
	local choices = {
		{ label = "Status   — show API key source",         sub = "status" },
		{ label = "Set      — save key to system keyring", sub = "set" },
		{ label = "Clear    — clear auth cache",            sub = "clear" },
		{ label = "Validate — test API key against API",    sub = "validate" },
	}

	-- snacks.picker.select takes a flat list of items, a format_item
	-- function (optional), and an on_choice callback. The default
	-- `format_item = tostring(item)` would render a table, which is
	-- why we provide a custom one.
	snacks.picker.select(choices, {
		prompt = "Mistral Codestral auth",
		format_item = function(item)
			return type(item) == "table" and (item.label or tostring(item)) or tostring(item)
		end,
	}, function(choice)
		if not choice then
			return
		end
		local sub
		if type(choice) == "table" then
			sub = choice.sub
		elseif type(choice) == "string" then
			sub = choice:lower():match("^(%w+)")
		end
		if not sub then
			vim.notify("[mistral-codestral] no auth subcommand selected", vim.log.levels.WARN)
			return
		end
		require("mistral-codestral.auth").auth_command({ fargs = { sub } })
	end)
end

-- Replace the auth command with the picker version
vim.api.nvim_create_user_command("MistralCodestralAuth", function(args)
	if not args or not args.fargs or #args.fargs == 0 then
		open_auth_picker()
	else
		-- Subcommand provided directly — pass through to the built-in
		require("mistral-codestral.auth").auth_command(args)
	end
end, {
	nargs = "?",
	desc = "Manage Mistral Codestral authentication (snacks picker when no subcommand)",
})

-- ----------------------------------------------------------------------------
-- 4. AI-explain command for the currently selected blink.cmp item.
-- ----------------------------------------------------------------------------
local function ai_explain_selected()
	if not blink.is_visible or not blink.is_visible() then
		vim.notify("[mistral-codestral] no completion menu open", vim.log.levels.INFO)
		return
	end

	local item = blink.get_selected_item and blink.get_selected_item()
	if not item then
		vim.notify("[mistral-codestral] no item selected", vim.log.levels.INFO)
		return
	end

	-- Use the full textEdit / insertText if available
	local code = item.textEdit and item.textEdit.newText or item.insertText or item.label or ""
	if code == "" then
		vim.notify("[mistral-codestral] selected item has no text", vim.log.levels.WARN)
		return
	end

	-- Truncate the prompt to keep the request cheap
	local preview = code:gsub("\n", " ⏎ ")
	if #preview > 200 then
		preview = preview:sub(1, 200) .. "..."
	end

	-- Build a small prompt asking for a 1-paragraph explanation
	local prompt = string.format(
		"<s>[INST] Explain in 2-3 sentences what the following %s code does. "
			.. "Mention inputs, outputs, and any side effects.\n\n```%s\n%s\n```[/INST]",
		item.source_name or "code",
		(vim.bo.filetype ~= "" and vim.bo.filetype) or "text",
		preview
	)

	-- Send as a chat-completion (not FIM) — use the /v1/chat/completions endpoint
	local http = require("mistral-codestral.http_client")
	local auth = require("mistral-codestral.auth")
	local api_key = auth.get_api_key()
	if not api_key then
		vim.notify("[mistral-codestral] no API key configured", vim.log.levels.ERROR)
		return
	end

	local request_data = {
		model = "codestral-latest",
		messages = {
			{ role = "user", content = prompt },
		},
		max_tokens = 200,
		temperature = 0.2,
	}

	vim.notify("[mistral-codestral] asking for explanation…", vim.log.levels.INFO)
	http.post("https://codestral.mistral.ai/v1/chat/completions", {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = "Bearer " .. api_key,
		},
		data = request_data,
		timeout = 15000,
	}, function(response, error)
		vim.schedule(function()
			if error then
				vim.notify("Mistral explain failed: " .. error, vim.log.levels.ERROR)
				return
			end
			local explanation
			if response and response.choices and response.choices[1] then
				local c = response.choices[1]
				explanation = c.message and c.message.content or c.text
			end
			if not explanation or explanation == "" then
				vim.notify("[mistral-codestral] empty explanation", vim.log.levels.WARN)
				return
			end
			-- Open a floating window with the explanation
			local lines = vim.split(explanation, "\n", { plain = true })
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
			vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

			local width = math.min(80, math.max(40, vim.o.columns - 20))
			local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.4))
			local win = vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				width = width,
				height = height,
				col = math.floor((vim.o.columns - width) / 2),
				row = math.floor((vim.o.lines - height) / 3),
				style = "minimal",
				border = "rounded",
				title = " Mistral Explain ",
				title_pos = "center",
			})
			-- Close on <Esc>/q/<CR>
			vim.keymap.set("n", "<Esc>", function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end, { buffer = buf, silent = true })
			vim.keymap.set("n", "q", function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end, { buffer = buf, silent = true })
			vim.keymap.set("n", "<CR>", function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end, { buffer = buf, silent = true })
		end)
	end)
end

vim.api.nvim_create_user_command("MistralExplainCompletion", ai_explain_selected, {
	desc = "Ask Mistral Codestral to explain the selected blink.cmp item",
})

-- Also expose a keymap that works inside the blink menu
vim.keymap.set({ "i", "n" }, "<C-g>", function()
	if blink.is_visible and blink.is_visible() then
		ai_explain_selected()
	else
		vim.notify("[mistral-codestral] <C-g> only fires while the blink menu is open", vim.log.levels.INFO)
	end
end, { desc = "Mistral: explain selected completion", silent = true })

-- ----------------------------------------------------------------------------
-- 5. :MistralCodestralCommitMsg — generate a commit message from `git diff`.
-- ----------------------------------------------------------------------------
local function generate_commit_message(opts)
	opts = opts or {}

	-- Locate the repo root
	local repo_root
	local ok, root = pcall(function()
		local dir = vim.fn.expand("%:p:h")
		if dir == "" then
			dir = vim.fn.getcwd()
		end
		while dir and dir ~= "" do
			if vim.uv.fs_stat(dir .. "/.git") then
				return dir
			end
			local parent = vim.fn.fnamemodify(dir, ":h")
			if parent == dir or parent == "" then
				return nil
			end
			dir = parent
		end
		return nil
	end)
	if not ok or not root then
		vim.notify(
			"[mistral-codestral] not inside a git repository",
			vim.log.levels.WARN
		)
		return
	end
	repo_root = root

	-- Build a list of diff sources to try, in order:
	--   1. `--staged` (if not banged)
	--   2. working tree (i.e. `git diff`) when nothing is staged
	--   3. (banged) the working tree only
	local function run_git(args)
		local h = io.popen(
			string.format("cd %s && git %s 2>/dev/null", vim.fn.shellescape(repo_root), args)
		)
		if not h then
			return ""
		end
		local out = h:read("*a")
		h:close()
		return out or ""
	end

	local diff
	if not opts.working_tree then
		diff = run_git("diff --staged")
		if not diff or diff:match("^%s*$") then
			-- Fall back to unstaged working-tree changes
			diff = run_git("diff")
		end
	else
		diff = run_git("diff")
	end

	if not diff or diff:match("^%s*$") then
		vim.notify(
			"[mistral-codestral] no changes to commit (git diff is empty)",
			vim.log.levels.INFO
		)
		return
	end


	-- Cap the diff at ~12 KB to keep the prompt reasonable
	if #diff > 12000 then
		diff = diff:sub(1, 12000) .. "\n\n... (truncated)"
	end

	-- Build a chat-completion prompt
	local prompt = string.format(
		"<s>[INST] Write a concise git commit message for the following diff. "
			.. "Use the Conventional Commits format (type(scope): subject). "
			.. "Subject line <= 72 chars. Add a short body (2-4 lines) summarizing the change. "
			.. "Do not include backticks or extra prose.\n\n%s[/INST]",
		diff
	)

	local http = require("mistral-codestral.http_client")
	local auth = require("mistral-codestral.auth")
	local api_key = auth.get_api_key()
	if not api_key then
		vim.notify("[mistral-codestral] no API key configured", vim.log.levels.ERROR)
		return
	end

	vim.notify("[mistral-codestral] generating commit message…", vim.log.levels.INFO)
	http.post("https://codestral.mistral.ai/v1/chat/completions", {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = "Bearer " .. api_key,
		},
		data = {
			model = "codestral-latest",
			messages = { { role = "user", content = prompt } },
			max_tokens = 256,
			temperature = 0.3,
		},
		timeout = 20000,
	}, function(response, error)
		vim.schedule(function()
			if error then
				vim.notify("Mistral commit-msg failed: " .. error, vim.log.levels.ERROR)
				return
			end
			local message
			if response and response.choices and response.choices[1] then
				local c = response.choices[1]
				message = c.message and c.message.content or c.text
			end
			if not message or message == "" then
				vim.notify("[mistral-codestral] empty commit message", vim.log.levels.WARN)
				return
			end
			-- Strip leading/trailing whitespace and code fences
			message = message:gsub("^%s+", ""):gsub("%s+$", "")
			message = message:gsub("^```[a-zA-Z]*\n", ""):gsub("\n```$", "")
			message = message:gsub("^`+", ""):gsub("`+$", "")

			-- Open the COMMIT_EDITMSG-equivalent scratch buffer
			local buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(message, "\n", { plain = true }))
			vim.api.nvim_buf_set_option(buf, "filetype", "gitcommit")
			vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
			vim.api.nvim_set_current_buf(buf)
			vim.cmd("file COMMIT_EDITMSG")
			vim.notify(
				"[mistral-codestral] review and :w to save (or :wq to commit)",
				vim.log.levels.INFO
			)
		end)
	end)
end

vim.api.nvim_create_user_command("MistralCodestralCommitMsg", function(args)
	-- Allow `!` to use working tree instead of staged
	generate_commit_message({ working_tree = args.bang })
end, {
	desc = "Generate a commit message from git diff (use :MistralCodestralCommitMsg! for unstaged changes)",
	bang = true,
})

-- ----------------------------------------------------------------------------
-- 6. Register :checkhealth integration
-- ----------------------------------------------------------------------------
vim.api.nvim_create_user_command("MistralCodestralHealth", function()
	local ok, health = pcall(require, "mistral-codestral.health")
	if ok and type(health.check) == "function" then
		health.check()
	else
		vim.notify("[mistral-codestral] health module not available", vim.log.levels.WARN)
	end
end, { desc = "Run mistral-codestral health check" })
