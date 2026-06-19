-- lua/mistral-codestral/blink.lua
-- blink.cmp v1.6+ source provider for Mistral Codestral.
-- Implements the standard source boilerplate (source.new(opts), get_completions, etc.)
-- Reference: https://cmp.saghen.dev/development/source-boilerplate

local M = {}

local uv = vim.uv or vim.loop

-- ----------------------------------------------------------------------------
-- Per-keyword completion cache (5s TTL)
-- ----------------------------------------------------------------------------
local completion_cache = {}
local CACHE_TTL_MS = 5000

local function generate_cache_key(line, bounds, cursor, filetype)
	-- bounds is 1-indexed for blink.cmp
	-- context.bounds = { start_col = 1-indexed, length }
	local prefix = line:sub(1, bounds.start_col + bounds.length - 1)
	local suffix = line:sub(bounds.start_col + bounds.length)
	return vim.fn.sha256(
		prefix:sub(-200) .. "|" .. suffix:sub(1, 200) .. "|" .. (filetype or "") .. "|" .. cursor[1] .. "," .. cursor[2]
	)
end

local function get_cached(key)
	local entry = completion_cache[key]
	if entry and (uv.now() - entry.timestamp) < CACHE_TTL_MS then
		return entry.items
	end
	return nil
end

local function set_cached(key, items)
	completion_cache[key] = { items = items, timestamp = uv.now() }
end

-- ----------------------------------------------------------------------------
-- Item builders — return blink.cmp-compatible LSP CompletionItem tables.
--
-- Key design decisions (after testing with blink.cmp v1.6+):
--   * sortText "00_/01_/02_" → AI items appear at the TOP of the menu,
--     BEFORE LSP/path/snippets (which sit in the "10_/20_/..." range).
--   * score_offset bumps the fuzzy-match score so AI wins ties.
--   * is_incomplete_forward/backward are set to FALSE in get_completions
--     so blink.cmp does not re-query on every keystroke (which would
--     cause the items to flicker and never be accepted cleanly).
--   * filterText mirrors what the user typed, not the full completion
--     body, so fuzzy matching against the keyword succeeds.
--   * textEdit.range is the exact keyword range (start..start+length),
--     NOT extended to end-of-line, so multi-line inserts don't clobber
--     existing text after the cursor.
-- ----------------------------------------------------------------------------

--- Extract the keyword being completed (e.g. "ad" when user typed "ad")
--- from the line + blink.cmp bounds. Returns "" when there's no keyword.
local function extract_keyword(line, bounds)
	if not bounds or not line then
		return ""
	end
	local sc = bounds.start_col or 1
	local len = bounds.length or 0
	if len <= 0 then
		return ""
	end
	return line:sub(sc, sc + len - 1)
end

local function build_items(completion, context, strategy, opts)
	local lines = vim.split(completion, "\n", { plain = true })
	local max_items = opts.max_items or 3
	local Kind = require("blink.cmp.types").CompletionItemKind

	-- Compute the exact 0-indexed range to replace.
	-- context.bounds.start_col is 1-indexed; end_col is end-exclusive in 0-indexed terms.
	local start_col = context.bounds and (context.bounds.start_col - 1) or 0
	local kw_len = context.bounds and (context.bounds.length or 0) or 0
	-- Only replace the keyword; do NOT extend to end-of-line (that would
	-- wipe out the user's text after the cursor when the completion is
	-- multi-line).
	local end_col = start_col + kw_len

	-- The keyword the user typed (e.g. "ad"). Used as filterText so
	-- blink.cmp can fuzzy-match AI items against the current keyword.
	local keyword = extract_keyword(context.line, context.bounds)

	-- 0-indexed line for the textEdit range
	local line0 = (context.cursor and context.cursor[1] and (context.cursor[1] - 1)) or 0

	local function make_text_edit(new_text)
		return {
			newText = new_text,
			range = {
				start = { line = line0, character = start_col },
				["end"] = { line = line0, character = end_col },
			},
		}
	end

	-- Main item: full completion
	local main_label = completion:gsub("\n", " ⏎ "):sub(1, 60) .. (#lines > 1 and "..." or "")
	local items = {
		{
			label = main_label,
			kind = #lines > 1 and Kind.Snippet or Kind.Text,
			detail = string.format("Codestral · %s · %d lines", strategy, #lines),
			documentation = {
				kind = "markdown",
				value = string.format(
					"```%s\n%s\n```\n\n**Strategy**: %s\n**Lines**: %d",
					context.filetype or "",
					completion,
					strategy,
					#lines
				),
			},
			textEdit = make_text_edit(completion),
			insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
			-- filterText: match against the keyword, not the full body.
			-- If there is no keyword (length=0) we use the first token of
			-- the completion so fuzzy matching still has *something* to
			-- score against.
			filterText = keyword ~= "" and keyword or (lines[1] or completion):gsub("%s.*$", ""),
			sortText = "00_codestral_full", -- top of the list
			score_offset = 10, -- boost for ties
		},
	}

	-- First-line-only variant (only useful for multi-line)
	if max_items > 1 and #lines > 1 and #items < max_items then
		table.insert(items, {
			label = "🤖 " .. lines[1]:sub(1, 80),
			kind = Kind.Text,
			detail = "Codestral · first line only",
			documentation = {
				kind = "markdown",
				value = string.format("```%s\n%s\n```", context.filetype or "", lines[1]),
			},
			textEdit = make_text_edit(lines[1]),
			insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
			filterText = keyword ~= "" and keyword or lines[1],
			sortText = "01_codestral_line", -- right below the main item
			score_offset = 8,
		})
	end

	-- Two-line variant
	if max_items > 1 and #lines > 2 and #items < max_items then
		local two = table.concat({ lines[1], lines[2] }, "\n")
		table.insert(items, {
			label = "🤖 " .. lines[1] .. " ⏎ " .. lines[2]:sub(1, 30) .. "...",
			kind = Kind.Snippet,
			detail = "Codestral · 2 lines",
			documentation = {
				kind = "markdown",
				value = string.format("```%s\n%s\n```", context.filetype or "", two),
			},
			textEdit = make_text_edit(two),
			insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
			filterText = keyword ~= "" and keyword or two,
			sortText = "02_codestral_two_lines",
			score_offset = 6,
		})
	end

	return items
end

-- ----------------------------------------------------------------------------
-- blink.cmp Source class
-- ----------------------------------------------------------------------------
--- @class blink.cmp.Source
local source = {}
source.__index = source

-- Constructor called by blink.cmp with `opts` from sources.providers
function source.new(opts)
	opts = opts or {}
	local self = setmetatable({}, source)
	self.opts = opts
	return self
end

-- Optional: enable on demand based on filetype/buftype
function source:enabled()
	local ok, mistral = pcall(require, "mistral-codestral")
	if not ok then
		return false
	end
	if not mistral.config().enabled then
		return false
	end
	return not mistral.is_buffer_excluded(self._bufnr or 0)
end

-- Optional: characters that should re-trigger this source
function source:get_trigger_characters()
	return { ".", ":", "(", "[", "{", " ", "\n", "\t", "=", ",", ";" }
end

-- Main entry: return completion items for the current keyword
function source:get_completions(ctx, callback)
	self._bufnr = ctx.bufnr
	local mistral = require("mistral-codestral")

	-- Bail if buffer is excluded (dashboard, terminals, etc.)
	if mistral.is_buffer_excluded(ctx.bufnr) then
		callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
		return function() end
	end

	-- Cache hit?
	local cache_key = generate_cache_key(ctx.line, ctx.bounds, ctx.cursor, vim.bo[ctx.bufnr].filetype)
	local cached = get_cached(cache_key)
	if cached then
		callback({ items = cached, is_incomplete_forward = false, is_incomplete_backward = false })
		return function() end
	end

	-- Build enhanced context and pick a strategy label
	local lsp_utils = require("mistral-codestral.lsp_utils")
	local enhanced = lsp_utils.get_enhanced_context()
	local cursor_context = lsp_utils.get_cursor_context()
	local strategy
	if cursor_context.in_comment then
		strategy = "comment"
	elseif cursor_context.in_function then
		strategy = "function_body"
	elseif cursor_context.in_string then
		strategy = "string"
	else
		strategy = "normal"
	end

	-- Fire the API call
	local cancelled = false
	local cancel_fn = function()
		cancelled = true
	end

	mistral.request_completion(function(completion)
		if cancelled then
			return
		end
		if not completion or completion == "" then
			callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
			return
		end

		local items = build_items(completion, {
			filetype = enhanced.filetype,
			cursor = ctx.cursor,
			line = ctx.line,
			bounds = ctx.bounds,
		}, strategy, self.opts)

		-- blink.cmp mutates the items table, so return a deep copy for the cache
		set_cached(cache_key, vim.deepcopy(items))
		-- is_incomplete_* = false: do not re-query on every keystroke;
		-- blink.cmp will only call us again when the keyword genuinely
		-- changes (cache miss). This prevents the menu from flickering.
		callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
	end, enhanced)

	return cancel_fn
end

-- Optional: lazy resolution for documentation/additionalTextEdits
function source:resolve(item, callback)
	-- Documentation is already populated in build_items; nothing more to do.
	callback(item)
end

-- ----------------------------------------------------------------------------
-- Public exports
-- ----------------------------------------------------------------------------
M.source = source
M.new = function(opts)
	return source.new(opts)
end
M.get_completions = function(_, ctx, callback)
	local s = source.new({})
	return s:get_completions(ctx, callback)
end
M.build_items = build_items
M.clear_cache = function()
	completion_cache = {}
end

return M
