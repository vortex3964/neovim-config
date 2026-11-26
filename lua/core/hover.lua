-- Smarter LSP hover for function calls.
--
-- `vim.lsp.buf.hover()` asks the server about the exact cursor position. After
-- accepting a function completion the cursor sits on the closing `)` of
-- `foo()`, where most servers return nothing useful (pyright/lua_ls/clangd/
-- typescript-tools return nil, gopls returns only the result type). Requesting
-- hover on the matching `(` returns the callee's full documentation on all of
-- them.
--
-- Hover is on demand only (`K`). If the server still has nothing, fall back to
-- signature help, which carries the signature.
local M = {}

local DEFAULT_OPTS = {
	border = "rounded",
	max_width = 90,
	max_height = 30,
	focus_id = "textDocument/hover",
	-- Match blink.cmp's documentation/signature panel exactly. These groups
	-- are defined at startup by core.cmp_hl, so this also works before
	-- blink.cmp has been loaded.
	winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
}

-- Control-flow keywords followed by `(` are not function calls.
local NOT_CALLS = {
	["if"] = true,
	["elseif"] = true,
	["while"] = true,
	["for"] = true,
	switch = true,
	catch = true,
	["return"] = true,
	sizeof = true,
	typeof = true,
	alignof = true,
	new = true,
	delete = true,
	assert = true,
	with = true,
	match = true,
	["until"] = true,
}

-- Calls almost never span more than this many lines. Bounding the backwards
-- scan keeps hover cheap even in very large files.
local SCAN_LIMIT = 100

--- @return string[] lines, integer first_row
local function scan_window(bufnr, row)
	local first = math.max(0, row - SCAN_LIMIT)
	return vim.api.nvim_buf_get_lines(bufnr, first, row + 1, false), first
end

--- Find the `(` matching the `)` at (row, col), scanning backwards.
--- @return integer? row 0-based
--- @return integer? col 0-based
local function matching_open_paren(bufnr, row, col)
	local lines, first = scan_window(bufnr, row)
	local depth = 0
	local r = row
	local i = col -- 1-based index of the character left of the `)`
	while r >= first do
		local line = lines[r - first + 1] or ""
		if r ~= row then
			i = #line
		end
		while i >= 1 do
			local ch = line:sub(i, i)
			if ch == ")" then
				depth = depth + 1
			elseif ch == "(" then
				if depth == 0 then
					return r, i - 1
				end
				depth = depth - 1
			end
			i = i - 1
		end
		r = r - 1
	end
end

--- Find the nearest unmatched `(` to the left of (row, col), i.e. the call
--- whose arguments contain the cursor.
--- @return integer? row 0-based
--- @return integer? col 0-based
local function enclosing_open_paren(bufnr, row, col)
	local lines, first = scan_window(bufnr, row)
	local depth = 0
	local r = row
	local i = col -- 1-based index of the character left of the cursor
	while r >= first do
		local line = lines[r - first + 1] or ""
		if r ~= row then
			i = #line
		end
		while i >= 1 do
			local ch = line:sub(i, i)
			if ch == ")" then
				depth = depth + 1
			elseif ch == "(" then
				if depth == 0 then
					return r, i - 1
				end
				depth = depth - 1
			end
			i = i - 1
		end
		r = r - 1
	end
end

--- Identifier immediately before the `(` at (row, paren_col).
--- @return string? name
--- @return integer? start_col 0-based
local function identifier_before_paren(bufnr, row, paren_col)
	local lines, first = scan_window(bufnr, row)
	local r = row
	local i = paren_col -- 1-based index of the character before `(`
	while r >= first do
		local line = lines[r - first + 1] or ""
		if r ~= row then
			i = #line
		end
		while i >= 1 do
			local ch = line:sub(i, i)
			if ch:match("[%w_$]") then
				local end_pos = i
				while i >= 1 and line:sub(i, i):match("[%w_$]") do
					i = i - 1
				end
				return line:sub(i + 1, end_pos), i
			elseif ch:match("%s") then
				i = i - 1
			else
				return nil
			end
		end
		r = r - 1
		if r >= first then
			i = #(lines[r - first + 1] or "")
		end
	end
end

--- Position of the callee's `(` when the cursor is inside a call.
--- @return integer? row 0-based
--- @return integer? col 0-based
local function callee_position(bufnr, row, col)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local char = line:sub(col + 1, col + 1)
	local pr, pc
	if char == ")" then
		pr, pc = matching_open_paren(bufnr, row, col)
	elseif char == "(" then
		pr, pc = row, col
	else
		pr, pc = enclosing_open_paren(bufnr, row, col)
	end
	if not pr then
		return nil
	end
	local name = identifier_before_paren(bufnr, pr, pc)
	if not name or NOT_CALLS[name] then
		return nil
	end
	return pr, pc
end

--- Is the cursor on a word that is immediately followed by `(`?
local function on_call_name(bufnr, row, col)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local i = col + 1 -- 1-based character under the cursor
	if not line:sub(i, i):match("[%w_$]") then
		return false
	end
	local start_pos = i
	while start_pos > 1 and line:sub(start_pos - 1, start_pos - 1):match("[%w_$]") do
		start_pos = start_pos - 1
	end
	local end_pos = i
	while end_pos < #line and line:sub(end_pos + 1, end_pos + 1):match("[%w_$]") do
		end_pos = end_pos + 1
	end
	local name = line:sub(start_pos, end_pos)
	if NOT_CALLS[name] then
		return false
	end
	local rest = line:sub(end_pos + 1)
	local spaces = rest:match("^%s*") or ""
	return rest:sub(#spaces + 1, #spaces + 1) == "("
end

--- Is the cursor inside a function call's argument list (including on `)`)?
function M.in_call(bufnr, row, col)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if row == nil or col == nil then
		local cursor = vim.api.nvim_win_get_cursor(0)
		row, col = cursor[1] - 1, cursor[2]
	end
	local pr = callee_position(bufnr, row, col)
	return pr ~= nil
end

local function hover_result_valid(result)
	local contents = result and result.contents
	if not contents then
		return false
	end
	if type(contents) == "string" then
		return #contents > 0
	end
	local len = #(vim.tbl_get(contents, "value") or vim.tbl_get(contents, 1, "value") or contents[1] or "")
	return len > 0
end

local function show_hover(result, opts)
	local contents = result.contents
	local format, lines
	if type(contents) == "table" and contents.kind == vim.lsp.protocol.MarkupKind.PlainText then
		format = "plaintext"
		lines = vim.split(contents.value or "", "\n", { trimempty = true })
	else
		format = "markdown"
		lines = vim.lsp.util.convert_input_to_markdown_lines(contents)
	end
	if #lines == 0 then
		return false
	end
	local _, win = vim.lsp.util.open_floating_preview(lines, format, opts)
	if win and opts.winhighlight and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_option_value("winhighlight", opts.winhighlight, { win = win })
	end
	return true
end

local function request_hover(bufnr, row, col, callback)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/hover" })
	if #clients == 0 then
		return callback(nil)
	end
	vim.lsp.buf_request_all(bufnr, "textDocument/hover", function(client)
		local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
		local byte_col = math.min(col, #line)
		return {
			textDocument = vim.lsp.util.make_text_document_params(bufnr),
			position = {
				line = row,
				character = vim.str_utfindex(line, client.offset_encoding, byte_col, false),
			},
		}
	end, function(results)
		for _, response in pairs(results) do
			if hover_result_valid(response.result) then
				return callback(response.result)
			end
		end
		callback(nil)
	end)
end

--- Hover the cursor, the enclosing call's `(`, or fall back to signature help.
--- @param opts? table passed to vim.lsp.util.open_floating_preview
--- @param forced_position? { [1]: integer, [2]: integer } 0-based row/col
local function smart_hover(opts, forced_position)
	opts = vim.tbl_extend("force", DEFAULT_OPTS, opts or {})

	local bufnr = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(win)
	local row, col = cursor[1] - 1, cursor[2]
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""

	local callee_row, callee_col = callee_position(bufnr, row, col)
	local in_call_context = callee_row ~= nil or on_call_name(bufnr, row, col)

	local candidates = {}
	if forced_position then
		candidates[1] = forced_position
	elseif line:sub(col + 1, col + 1) == ")" then
		-- Hovering `)` yields nothing useful; the matching `(` has the docs.
		if callee_row then
			candidates[#candidates + 1] = { callee_row, callee_col }
		end
		candidates[#candidates + 1] = { row, col }
	else
		candidates[#candidates + 1] = { row, col }
		if callee_row and (callee_row ~= row or callee_col ~= col) then
			candidates[#candidates + 1] = { callee_row, callee_col }
		end
	end

	local function stale()
		if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
			return true
		end
		if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_get_current_win() ~= win then
			return true
		end
		local current = vim.api.nvim_win_get_cursor(win)
		return current[1] - 1 ~= row or current[2] ~= col
	end

	local function fallback()
		if in_call_context then
			-- Don't reuse the hover focus id for the signature float.
			local sig_opts = vim.tbl_extend("force", opts, {})
			sig_opts.focus_id = nil
			vim.lsp.buf.signature_help(sig_opts)
		elseif not opts.silent then
			vim.notify("No information available", vim.log.levels.INFO)
		end
	end

	local function try(index)
		local position = candidates[index]
		if not position then
			return fallback()
		end
		request_hover(bufnr, position[1], position[2], function(result)
			if stale() then
				return
			end
			if result and show_hover(result, opts) then
				return
			end
			try(index + 1)
		end)
	end
	try(1)
end

--- `K`: hover the symbol under the cursor, with function-call fallbacks.
function M.hover(opts)
	smart_hover(opts)
end

--- Show the enclosing function's docs on demand. This is not wired to
--- CursorHold/CursorHoldI; hover should only appear when the user asks for it.
function M.auto_hover()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1] - 1, cursor[2]
	-- Prefer the name under the cursor over an enclosing call, so
	-- `foo(greet|(...))` shows greet's docs rather than foo's.
	if on_call_name(bufnr, row, col) then
		return smart_hover({ silent = true, focus = false })
	end
	local callee_row, callee_col = callee_position(bufnr, row, col)
	if callee_row then
		return smart_hover({ silent = true, focus = false }, { callee_row, callee_col })
	end
end

return M
