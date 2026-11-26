-- Rich documentation for blink.cmp completion items.
--
-- Some language servers (notably pyright) return no documentation at all for
-- completion items of user-defined functions. blink's documentation window
-- therefore stays hidden, even though `K` (textDocument/hover) shows the full
-- signature and docstring.
--
-- This module listens to blink's selection events, asks `textDocument/hover`
-- about the selected item in an unsaved, temporary copy of the current buffer
-- (same directory, so imports/relative paths still resolve), and feeds the
-- result into blink's documentation window. It also adds a "Loading…"
-- placeholder so the window opens immediately while the hover request is in
-- flight.
--
-- Nothing is written to disk: the temporary document only exists as a
-- `textDocument/didOpen` notification for the LSP clients.

local M = {}

local api = vim.api
local uv = vim.uv or vim.loop

local Kind = vim.lsp.protocol.CompletionItemKind
local CODE_KINDS = {
	[Kind.Function] = true,
	[Kind.Method] = true,
	[Kind.Constructor] = true,
	[Kind.Class] = true,
	[Kind.Interface] = true,
	[Kind.Struct] = true,
	[Kind.Enum] = true,
}

local PLACEHOLDER = "*Loading documentation…*"

local generation = 0
local preview_id = 0

--- @class CoreCmpDocsPending
--- @field timer? uv.uv_timer_t
--- @field cancel? fun()
--- @field item? blink.cmp.CompletionItem
--- @field original_documentation? string|table
--- @field placeholder boolean
local pending = {
	timer = nil,
	cancel = nil,
	item = nil,
	original_documentation = nil,
	placeholder = false,
}

--- @class CoreCmpDocsCache
--- @field context_id? number
--- @field values table<string, table|false>
local cache = { context_id = nil, values = {} }

local function markdown(value)
	return { kind = "markdown", value = value }
end

local function documentation_text(documentation)
	if type(documentation) == "string" then
		return documentation
	end
	if type(documentation) == "table" then
		-- MarkupContent or MarkedString: both carry the text in `value`.
		if type(documentation.value) == "string" then
			return documentation.value
		end
	end
	return ""
end

--- Normalize an LSP hover result into a markdown documentation value.
--- @param contents lsp.MarkupContent|lsp.MarkedString|lsp.MarkedString[]|string|nil
--- @return table? documentation
local function normalize_hover(contents)
	if contents == nil then
		return nil
	end

	local doc
	if type(contents) == "string" then
		doc = markdown(contents)
	elseif type(contents) == "table" and type(contents.kind) == "string" and type(contents.value) == "string" then
		doc = contents
	else
		-- MarkedString or an array of MarkedStrings/MarkupContents.
		local ok, lines = pcall(vim.lsp.util.convert_input_to_markdown_lines, contents)
		if not ok or not lines or #lines == 0 then
			return nil
		end
		doc = markdown(table.concat(lines, "\n"))
	end

	if documentation_text(doc) == "" then
		return nil
	end
	return doc
end

--- Strip `foo(args)` down to `foo`.
local function bare_name(label)
	if type(label) ~= "string" then
		return ""
	end
	return label:match("^[^%(%s]+") or ""
end

local function cache_key(context, item)
	return table.concat({ context.id, item.source_id or "", item.label or "" }, "\0")
end

local function item_is_selected(context, item)
	local ok, list = pcall(require, "blink.cmp.completion.list")
	if not ok or not list.context or list.context.id ~= context.id then
		return false
	end
	if list.get_selected_item() ~= item then
		return false
	end
	local menu = require("blink.cmp.completion.windows.menu")
	return menu.win:is_open()
end

--- Does the hover documentation already include the item's detail line?
local function detail_overlaps(documentation, detail)
	if type(detail) ~= "string" or detail == "" then
		return false
	end
	local text = documentation_text(documentation)
	if text == "" then
		return false
	end
	local first_line = detail:match("^[^\n]+") or detail
	return text:find(first_line, 1, true) ~= nil
end

--- Render documentation into blink's documentation window and open it.
local function show_docs(docs, item, documentation)
	local detail = item.detail
	-- Servers like lua_ls put the signature in both `detail` and the hover
	-- markdown. Avoid printing it twice in the docs window.
	if detail_overlaps(documentation, detail) then
		detail = nil
	end

	local config = require("blink.cmp.config").completion.documentation
	require("blink.cmp.lib.window.docs").render_detail_and_documentation({
		bufnr = docs.win:get_buf(),
		detail = detail,
		documentation = documentation,
		max_width = docs.win.config.max_width,
		use_treesitter_highlighting = config.treesitter_highlighting,
	})
	docs.shown_item = item
	docs.win:open()
	docs.win:set_cursor({ 1, 0 })
	docs.update_position()
end

--- Put hover docs into blink's docs window, if the item is still selected.
local function apply_docs(context, item, hover_docs)
	if not item_is_selected(context, item) then
		return
	end

	local docs = require("blink.cmp.completion.windows.documentation")
	local current = documentation_text(item.documentation)
	local hover = documentation_text(hover_docs)

	-- Don't replace richer documentation that the server already provided.
	if current ~= "" and #current > #hover and not current:find(PLACEHOLDER, 1, true) then
		return
	end

	-- blink may have already resolved the item; keep that copy in sync too.
	local shown = docs.shown_item
	if shown and shown.label == item.label and shown.source_id == item.source_id then
		shown.documentation = hover_docs
	else
		shown = item
	end

	item.documentation = hover_docs
	show_docs(docs, shown, hover_docs)
end

--- Build an unsaved copy of the buffer with the completion item inserted.
--- @return string[]? lines
--- @return integer? row 0-based
--- @return integer? col 0-based byte column
--- @return string? path
local function build_preview(context, item)
	local bufnr = context.bufnr
	if not api.nvim_buf_is_valid(bufnr) then
		return nil
	end

	local path = api.nvim_buf_get_name(bufnr)
	if path == "" then
		return nil
	end

	local bounds = context.bounds
	local row = bounds.line_number
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local line = lines[row]
	if not line then
		return nil
	end

	local insert = bare_name(item.label)
	if insert == "" then
		insert = bare_name(item.insertText)
	end
	if insert == "" then
		return nil
	end

	local start_col = math.max(1, math.min(bounds.start_col, #line + 1))
	local length = math.max(0, bounds.length)
	lines[row] = line:sub(1, start_col - 1) .. insert .. line:sub(start_col + length)

	return lines, row - 1, start_col - 1 + math.floor(#insert / 2), path
end

--- Ask every hover-capable client about the previewed item.
--- @param context blink.cmp.Context
--- @param item blink.cmp.CompletionItem
--- @param on_done fun(docs: table?)
--- @return fun()? cancel
local function fetch_hover(context, item, on_done)
	local lines, row, byte_col, path = build_preview(context, item)
	if not lines or not path then
		on_done(nil)
		return function() end
	end

	local clients = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = context.bufnr, method = "textDocument/hover" })) do
		if client.server_capabilities and client.server_capabilities.hoverProvider then
			clients[#clients + 1] = client
		end
	end
	if #clients == 0 then
		on_done(nil)
		return function() end
	end

	preview_id = preview_id + 1
	local dir = vim.fs.dirname(path)
	if dir == "" then
		dir = "."
	end
	local base = vim.fs.basename(path)
	local preview_path
	repeat
		preview_path = dir .. "/nvim_hover_" .. preview_id .. "_" .. base
		preview_id = preview_id + 1
	until vim.fn.filereadable(preview_path) == 0 and vim.fn.bufnr(preview_path) == -1
	local uri = vim.uri_from_fname(preview_path)
	local text = table.concat(lines, "\n") .. "\n"
	local language_id = vim.bo[context.bufnr].filetype
	local line_text = lines[row + 1] or ""

	local opened = {}
	local requests = {}
	local best = nil
	local finished = false
	local cancelled = false
	local timeout = uv.new_timer()

	local function cleanup()
		if timeout and not timeout:is_closing() then
			timeout:stop()
			timeout:close()
		end
		for _, request in ipairs(requests) do
			if request.id then
				pcall(request.client.cancel_request, request.client, request.id)
			end
		end
		requests = {}
		for _, client in ipairs(opened) do
			pcall(client.notify, client, "textDocument/didClose", { textDocument = { uri = uri } })
		end
		opened = {}
	end

	local function finish()
		if finished then
			return
		end
		finished = true
		cleanup()
		if not cancelled then
			on_done(best)
		end
	end

	for _, client in ipairs(clients) do
		if finished or cancelled then
			break
		end

		pcall(client.notify, client, "textDocument/didOpen", {
			textDocument = {
				uri = uri,
				languageId = language_id,
				version = 0,
				text = text,
			},
		})
		opened[#opened + 1] = client

		-- Register the request before sending it: a handler that responds
		-- synchronously would otherwise call the callback before the request
		-- id exists and finish() while the timeout is still uninitialised.
		local entry = { client = client }
		requests[#requests + 1] = entry

		local ok, request_id = client:request("textDocument/hover", {
			textDocument = { uri = uri },
			position = {
				line = row,
				character = vim.str_utfindex(line_text, client.offset_encoding, byte_col, false),
			},
		}, function(err, result)
			requests = vim.tbl_filter(function(request)
				return request ~= entry
			end, requests)

			if not cancelled and not err and result then
				local doc = normalize_hover(result.contents)
				if doc and (best == nil or #documentation_text(doc) > #documentation_text(best)) then
					best = doc
				end
			end

			if not finished and #requests == 0 then
				finish()
			end
		end)

		if ok and request_id then
			entry.id = request_id
		else
			requests = vim.tbl_filter(function(request)
				return request ~= entry
			end, requests)
		end
	end

	if finished then
		return function() end
	end

	if #requests == 0 then
		finish()
		return function() end
	end

	if timeout then
		timeout:start(
			1200,
			0,
			vim.schedule_wrap(function()
				if not finished then
					finish()
				end
			end)
		)
	end

	return function()
		if finished then
			return
		end
		cancelled = true
		finished = true
		cleanup()
	end
end

local function restore_pending()
	if pending.item ~= nil and pending.placeholder then
		pending.item.documentation = pending.original_documentation
	end
	pending.item = nil
	pending.original_documentation = nil
	pending.placeholder = false
end

local function cancel_pending()
	generation = generation + 1
	if pending.timer ~= nil then
		pending.timer:stop()
		if not pending.timer:is_closing() then
			pending.timer:close()
		end
		pending.timer = nil
	end
	if pending.cancel ~= nil then
		pending.cancel()
		pending.cancel = nil
	end
	restore_pending()
end

--- Called whenever blink selects a completion item.
--- @param context blink.cmp.Context
--- @param item blink.cmp.CompletionItem?
function M.on_select(context, item)
	if not context or not item then
		cancel_pending()
		return
	end

	if item.source_id ~= "lsp" or not CODE_KINDS[item.kind] then
		cancel_pending()
		return
	end

	local existing = documentation_text(item.documentation)
	-- Fetch when there are no docs, or only a signature block (pyright), or
	-- when the item has nothing but a detail string. Rich server docs are
	-- left alone to avoid pointless requests.
	local fetch = existing == ""
		or (existing:find(PLACEHOLDER, 1, true) ~= nil)
		or (#existing < 160 and not existing:find("\n%-%-%-\n", 1))
	if not fetch then
		cancel_pending()
		return
	end

	cancel_pending()

	if cache.context_id ~= context.id then
		cache.context_id = context.id
		cache.values = {}
	end

	local key = cache_key(context, item)
	local cached = cache.values[key]
	if cached ~= nil then
		if cached ~= false then
			apply_docs(context, item, cached)
		end
		return
	end

	-- Open the documentation window immediately, even before hover responds.
	-- Remember whether the placeholder is ours: when it is not, a failed
	-- hover must leave the server-provided docs untouched.
	local owns_placeholder = existing == "" and (item.detail == nil or item.detail == "")
	if owns_placeholder then
		pending.item = item
		pending.original_documentation = item.documentation
		pending.placeholder = true
		item.documentation = markdown(PLACEHOLDER)
	end

	local gen = generation
	local timer = uv.new_timer()
	if not timer then
		restore_pending()
		return
	end
	pending.timer = timer
	timer:start(
		40,
		0,
		vim.schedule_wrap(function()
			if not timer:is_closing() then
				timer:close()
			end
			if pending.timer == timer then
				pending.timer = nil
			end
			if gen ~= generation or not item_is_selected(context, item) then
				return
			end

			local cancel
			cancel = fetch_hover(context, item, function(hover_docs)
				if pending.cancel == cancel then
					pending.cancel = nil
				end
				if gen ~= generation or not item_is_selected(context, item) then
					return
				end

				cache.values[key] = hover_docs or false
				pending.item = nil
				pending.original_documentation = nil
				pending.placeholder = false

				if hover_docs then
					apply_docs(context, item, hover_docs)
				elseif owns_placeholder then
					-- Nothing found and the placeholder was ours: remove it and
					-- hide the window. Server-provided docs are left alone.
					item.documentation = nil
					local docs = require("blink.cmp.completion.windows.documentation")
					local shown = docs.shown_item
					if shown and shown.label == item.label and shown.source_id == item.source_id then
						docs.close()
					end
				end
			end)
			pending.cancel = cancel
		end)
	)
end

--- Register the selection hook. Safe to call once after blink.cmp.setup().
function M.setup()
	if M.did_setup then
		return
	end
	M.did_setup = true

	local ok, list = pcall(require, "blink.cmp.completion.list")
	if not ok then
		return
	end

	-- blink re-renders a resolved copy of each item. That copy can carry a
	-- stale `documentation` value (nil or the "Loading…" placeholder), so
	-- substitute our cached hover docs just before rendering.
	local ok_docs, docs = pcall(require, "blink.cmp.completion.windows.documentation")
	if ok_docs then
		local original_show_item = docs.show_item
		---@diagnostic disable-next-line: duplicate-set-field
		docs.show_item = function(context, doc_item)
			if context and doc_item then
				local cached = cache.values[cache_key(context, doc_item)]
				if cached then
					local copy = {}
					for field, value in pairs(doc_item) do
						copy[field] = value
					end
					copy.documentation = cached
					doc_item = copy
				end
			end
			return original_show_item(context, doc_item)
		end
	end

	list.select_emitter:on(function(event)
		M.on_select(event.context, event.item)
	end)

	-- Drop per-context caches when the menu closes so they don't accumulate.
	vim.api.nvim_create_autocmd("User", {
		pattern = "BlinkCmpHide",
		callback = function()
			-- A new menu may have opened before this scheduled event ran.
			local current = require("blink.cmp.completion.list").context
			if current ~= nil then
				return
			end
			cancel_pending()
			cache.context_id = nil
			cache.values = {}
		end,
	})
end

return M
