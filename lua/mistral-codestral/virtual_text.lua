-- lua/mistral-codestral/virtual_text.lua
-- Ghost-text virtual completion (Windsurf-style).
-- Forked to use vim.uv instead of vim.loop.

local M = {}

local uv = vim.uv or vim.loop

local namespace = vim.api.nvim_create_namespace("mistral_codestral_virtual_text")
local timer = nil
local current_completions = {}
local current_index = 0
local config = {}
local mistral_module = nil

local status = {
	state = "idle", -- "idle" | "waiting" | "completions" | "error"
	current = 0,
	total = 0,
	strategy = nil, -- "normal" | "comment" | "function_body" | "string"
	model = nil, -- "codestral-latest"
	last_error = nil, -- string (set if the last request errored)
	request_started_at = nil, -- uv.now() timestamp of the in-flight request
	completion_row = nil,
	completion_col = nil,
	completion_bufnr = nil,
}

-- Clear all virtual text and reset state
local function clear_virtual_text()
	if timer then
		pcall(vim.fn.timer_stop, timer)
		timer = nil
	end

	local ok, bufnr = pcall(vim.api.nvim_get_current_buf)
	if ok and bufnr then
		pcall(vim.api.nvim_buf_clear_namespace, bufnr, namespace, 0, -1)
	end

	current_completions = {}
	current_index = 0
	status = {
		state = "idle",
		current = 0,
		total = 0,
		strategy = nil,
		model = status.model, -- keep the model label
		last_error = nil,
		request_started_at = nil,
		completion_row = nil,
		completion_col = nil,
		completion_bufnr = nil,
	}
	pcall(M.refresh_statusbar)
end

-- Strip overlap with text after the cursor and matching prefix before the cursor
local function validate_completion_prefix(completion_line, current_line, cursor_col)
	if not completion_line or completion_line == "" then
		return ""
	end

	local line_before_cursor = current_line:sub(1, cursor_col)
	local line_after_cursor = current_line:sub(cursor_col + 1)

	-- Strip leading overlap with what's already on the line
	if line_after_cursor and #line_after_cursor > 0 then
		local overlap_length = 0
		local max_check = math.min(#completion_line, #line_after_cursor)
		for i = 1, max_check do
			if completion_line:sub(i, i) == line_after_cursor:sub(i, i) then
				overlap_length = i
			else
				break
			end
		end
		if overlap_length > 0 then
			completion_line = completion_line:sub(overlap_length + 1)
		end
	end

	-- Strip matching prefix that's already been typed
	local matching_prefix = 0
	local max_prefix_check = math.min(#completion_line, #line_before_cursor)
	for len = 1, max_prefix_check do
		local line_suffix = line_before_cursor:sub(-len)
		local completion_prefix = completion_line:sub(1, len)
		if line_suffix == completion_prefix then
			matching_prefix = len
		end
	end
	if matching_prefix > 0 then
		return completion_line:sub(matching_prefix + 1)
	end
	return completion_line
end

-- Render a completion as virtual text on subsequent lines (eol)
local function show_virtual_text(completion, cursor_row, cursor_col)
	if not completion or completion == "" then
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.split(completion, "\n", { plain = true })
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if cursor_row >= line_count then
		return
	end

	local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1]
	if not current_line then
		return
	end

	status.completion_row = cursor_row
	status.completion_col = cursor_col
	status.completion_bufnr = bufnr

	vim.api.nvim_buf_clear_namespace(bufnr, namespace, cursor_row, cursor_row + #lines + 5)

	for i, line in ipairs(lines) do
		if line ~= "" then
			local row = cursor_row + i - 1
			if row >= line_count then
				break
			end
			local display_text = line
			if i == 1 then
				display_text = validate_completion_prefix(line, current_line, cursor_col)
			end
			if display_text ~= "" then
				local extmark_col = (i == 1) and cursor_col or 0
				pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, row, extmark_col, {
					virt_text = { { display_text, "Comment" } },
					virt_text_pos = "eol",
					priority = (config.virtual_text and config.virtual_text.priority) or 100,
					hl_mode = "combine",
				})
			end
		end
	end
end

local function request_virtual_completions()
	if status.state == "waiting" then
		return
	end
	status.state = "waiting"
	status.request_started_at = uv.now()
	status.last_error = nil
	if not mistral_module or not mistral_module.config() then
		mistral_module = require("mistral-codestral")
	end
	status.model = (mistral_module.config() and mistral_module.config().model) or status.model
	M.refresh_statusbar()

	if not mistral_module then
		mistral_module = require("mistral-codestral")
	end

	local context = mistral_module.get_fim_context_enhanced()
	mistral_module.request_completion(function(completion)
		if completion and completion ~= "" then
			current_completions = { completion }
			current_index = 1
			status.state = "completions"
			status.current = 1
			status.total = #current_completions
			-- Try to infer the strategy from the cursor context
			local lsp_utils_ok, lsp_utils = pcall(require, "mistral-codestral.lsp_utils")
			if lsp_utils_ok then
				local ctx = lsp_utils.get_cursor_context()
				if ctx.in_comment then
					status.strategy = "comment"
				elseif ctx.in_string then
					status.strategy = "string"
				elseif ctx.in_function then
					status.strategy = "function_body"
				else
					status.strategy = "normal"
				end
			end
			status.request_started_at = nil

			local cursor = vim.api.nvim_win_get_cursor(0)
			show_virtual_text(completion, cursor[1] - 1, cursor[2])
		else
			status.state = "idle"
			status.current = 0
			status.total = 0
			status.strategy = nil
			status.request_started_at = nil
			status.completion_row = nil
			status.completion_col = nil
			status.completion_bufnr = nil
			current_completions = {}
			current_index = 0
		end
		M.refresh_statusbar()
	end, context)
end

-- Debounced trigger (called from TextChangedI)
function M.debounced_complete()
	if timer then
		pcall(vim.fn.timer_stop, timer)
	end
	local delay = (config.virtual_text and config.virtual_text.idle_delay) or 800
	timer = vim.fn.timer_start(delay, function()
		request_virtual_completions()
	end)
end

-- Immediate trigger
function M.complete()
	if timer then
		pcall(vim.fn.timer_stop, timer)
		timer = nil
	end
	request_virtual_completions()
end

-- Cycle if we have completions, otherwise request a fresh one
function M.cycle_or_complete()
	if #current_completions > 0 then
		M.cycle_completions(1)
	else
		M.complete()
	end
end

-- Cycle through current completions
function M.cycle_completions(direction)
	if #current_completions == 0 then
		return
	end
	current_index = current_index + direction
	if current_index > #current_completions then
		current_index = 1
	elseif current_index < 1 then
		current_index = #current_completions
	end
	status.current = current_index
	M.refresh_statusbar()

	local cursor = vim.api.nvim_win_get_cursor(0)
	show_virtual_text(current_completions[current_index], cursor[1] - 1, cursor[2])
end

local function process_first_line(completion, current_line, cursor_col)
	local completion_lines = vim.split(completion, "\n", { plain = true })
	if #completion_lines == 0 then
		return ""
	end
	local first = completion_lines[1]
	local processed = validate_completion_prefix(first, current_line, cursor_col)
	if processed ~= "" then
		completion_lines[1] = processed
		return table.concat(completion_lines, "\n")
	end
	table.remove(completion_lines, 1)
	if #completion_lines > 0 then
		return table.concat(completion_lines, "\n")
	end
	return ""
end

-- Accept the current completion
function M.accept()
	if #current_completions == 0 or current_index == 0 then
		return
	end
	local completion = current_completions[current_index]
	local bufnr = vim.api.nvim_get_current_buf()
	if status.completion_bufnr and bufnr ~= status.completion_bufnr then
		clear_virtual_text()
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1] or ""
	completion = process_first_line(completion, current_line, cursor[2])

	clear_virtual_text()
	if completion ~= "" then
		if not mistral_module then
			mistral_module = require("mistral-codestral")
		end
		mistral_module.insert_completion(completion)
	end
end

-- Accept only the next whitespace-delimited word
function M.accept_word()
	if #current_completions == 0 or current_index == 0 then
		return
	end
	local completion = current_completions[current_index]
	local bufnr = vim.api.nvim_get_current_buf()
	if status.completion_bufnr and bufnr ~= status.completion_bufnr then
		clear_virtual_text()
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1] or ""
	local first_line = vim.split(completion, "\n", { plain = true })[1] or ""
	local processed = validate_completion_prefix(first_line, current_line, cursor[2])

	clear_virtual_text()
	if processed ~= "" then
		local word = processed:match("^%S+") or processed
		if not mistral_module then
			mistral_module = require("mistral-codestral")
		end
		mistral_module.insert_completion(word)
	end
end

-- Accept just the first line of the completion
function M.accept_line()
	if #current_completions == 0 or current_index == 0 then
		return
	end
	local completion = current_completions[current_index]
	local bufnr = vim.api.nvim_get_current_buf()
	if status.completion_bufnr and bufnr ~= status.completion_bufnr then
		clear_virtual_text()
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1] or ""
	local first_line = vim.split(completion, "\n", { plain = true })[1] or ""
	local processed = validate_completion_prefix(first_line, current_line, cursor[2])

	clear_virtual_text()
	if processed ~= "" then
		if not mistral_module then
			mistral_module = require("mistral-codestral")
		end
		mistral_module.insert_completion(processed)
	end
end

-- ============================================================================
-- Status helpers for statusline integration
-- ============================================================================
-- We expose three levels of detail:
--   M.status_string()  -- short text, e.g. "◐ 1.2s" or "● ready (1)"
--   M.status_label()   -- { text, color, icon, tooltip } for rich statuslines
--   M.status()         -- the raw status table (state, current, total, strategy, ...)
-- ============================================================================

-- Pretty-print a strategy name (e.g. "function_body" -> "function body")
local function pretty_strategy(s)
	if not s or s == "" or s == "normal" then
		return nil
	end
	return s:gsub("_", " ")
end

-- Format the elapsed time of the in-flight request
local function elapsed_ms()
	if not status.request_started_at then
		return nil
	end
	local ms = uv.now() - status.request_started_at
	if ms < 1000 then
		return string.format("%dms", ms)
	end
	return string.format("%.1fs", ms / 1000)
end

--- Short, single-token string for compact statuslines.
function M.status_string()
	if status.state == "waiting" then
		local ms = elapsed_ms()
		return ms and ("◐ " .. ms) or "◐"
	elseif status.state == "completions" and status.total > 0 then
		if status.total > 1 then
			return string.format("● %d/%d", status.current, status.total)
		end
		return "●"
	elseif status.state == "error" then
		return "✖"
	end
	return "─"
end

--- Rich label for statusline components. Returns a table:
---   { text = "...", icon = "...", color = "fg=#xxxxxx", tooltip = "..." }
function M.status_label()
	local s = status
	local text, icon, color, tooltip

	if s.state == "waiting" then
		local ms = elapsed_ms()
		local strategy = pretty_strategy(s.strategy)
		text = ms and ("waiting " .. ms) or "waiting"
		if strategy then
			text = text .. " (" .. strategy .. ")"
		end
		icon = "◐"
		color = "#ffb347" -- orange
		tooltip = "Mistral Codestral: waiting for API response"
	elseif s.state == "completions" and s.total > 0 then
		local strategy = pretty_strategy(s.strategy)
		if s.total > 1 then
			text = string.format("ready (%d of %d)", s.current, s.total)
		else
			text = "ready"
		end
		if strategy then
			text = text .. " • " .. strategy
		end
		icon = "●"
		color = "#6aab73" -- green
		tooltip = string.format("Mistral Codestral: %d completion(s) available", s.total)
		if s.strategy then
			tooltip = tooltip .. " [strategy: " .. s.strategy .. "]"
		end
	elseif s.state == "error" then
		text = "error"
		icon = "✖"
		color = "#f85149" -- red
		tooltip = "Mistral Codestral: " .. (s.last_error or "request failed")
	else
		-- idle: show model name in dim color so the user knows the plugin is wired
		text = s.model or "codestral"
		icon = "─"
		color = "#7a7e85" -- gray
		tooltip = "Mistral Codestral idle (model: " .. (s.model or "default") .. ")"
	end

	return { text = text, icon = icon, color = color, tooltip = tooltip }
end

--- Raw status table (backward compat with existing lualine component).
function M.status()
	return vim.deepcopy(status)
end

local statusbar_refresh_fn = function() end

function M.set_statusbar_refresh(fn)
	statusbar_refresh_fn = fn
end

function M.refresh_statusbar()
	statusbar_refresh_fn()
end

-- Setup virtual text
function M.setup(mistral_config)
	config = mistral_config
	local vt_config = config.virtual_text
	if not vt_config then
		return
	end

	-- Auto-trigger setup
	if not vt_config.manual then
		local group = vim.api.nvim_create_augroup("MistralCodestralVirtualText", { clear = true })

		vim.api.nvim_create_autocmd({ "TextChangedI" }, {
			group = group,
			callback = function()
				if not mistral_module then
					mistral_module = require("mistral-codestral")
				end
				if mistral_module.is_buffer_excluded() then
					return
				end

				local ft = vim.bo.filetype
				local ft_enabled = vt_config.filetypes[ft]
				if ft_enabled == false then
					return
				end
				if ft_enabled == nil and not vt_config.default_filetype_enabled then
					return
				end

				local min_chars = vt_config.min_chars or 1
				if min_chars > 1 then
					local cursor = vim.api.nvim_win_get_cursor(0)
					local current_line = vim.api.nvim_get_current_line()
					local line_before_cursor = current_line:sub(1, cursor[2])
					local current_word = line_before_cursor:match("%S+$") or ""
					if #current_word < min_chars then
						return
					end
				end

				M.debounced_complete()
			end,
		})

		vim.api.nvim_create_autocmd("ModeChanged", {
			group = group,
			callback = function()
				if vim.fn.mode() ~= "i" then
					clear_virtual_text()
				end
			end,
		})

		vim.api.nvim_create_autocmd("CursorMovedI", {
			group = group,
			callback = function()
				if #current_completions == 0 or not status.completion_row then
					return
				end
				local cursor = vim.api.nvim_win_get_cursor(0)
				if
					cursor[1] - 1 ~= status.completion_row
					or math.abs(cursor[2] - (status.completion_col or 0)) > 5
				then
					clear_virtual_text()
				end
			end,
		})

		vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
			group = group,
			callback = clear_virtual_text,
		})
	end

	-- Key bindings
	if vt_config.key_bindings and vt_config.key_bindings ~= false then
		local b = vt_config.key_bindings
		if b.accept then
			vim.keymap.set("i", b.accept, function()
				if #current_completions > 0 and current_index > 0 then
					M.accept()
				end
			end, { desc = "Accept Codestral completion", silent = true })
		end
		if b.accept_word then
			vim.keymap.set("i", b.accept_word, M.accept_word, { desc = "Accept Codestral word", silent = true })
		end
		if b.accept_line then
			vim.keymap.set("i", b.accept_line, M.accept_line, { desc = "Accept Codestral line", silent = true })
		end
		if b.next then
			vim.keymap.set("i", b.next, function()
				M.cycle_completions(1)
			end, { desc = "Next Codestral completion", silent = true })
		end
		if b.prev then
			vim.keymap.set("i", b.prev, function()
				M.cycle_completions(-1)
			end, { desc = "Previous Codestral completion", silent = true })
		end
		if b.clear then
			vim.keymap.set("i", b.clear, clear_virtual_text, { desc = "Clear Codestral completion", silent = true })
			vim.keymap.set("n", b.clear, clear_virtual_text, { desc = "Clear Codestral completion", silent = true })
		end
	end

	vim.api.nvim_create_user_command("MistralCodestralVirtualComplete", M.complete, {
		desc = "Manually trigger Codestral virtual text completion",
	})
	vim.api.nvim_create_user_command("MistralCodestralVirtualClear", clear_virtual_text, {
		desc = "Clear Codestral virtual text",
	})
end

return M
