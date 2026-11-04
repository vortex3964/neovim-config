-- SQL language server (sqls) connection setup.
--
-- The old sqlls server (sql-language-server) crashes on modern Node because
-- one of its dependencies uses a package subpath that is no longer exported.
-- `sqls` is a Go server with real MySQL / PostgreSQL / SQLite / MSSQL support.
--
-- sqls is only schema-aware when it has a database connection. Instead of
-- asking you to duplicate credentials in a second config file, this module
-- reuses the connections already saved by vim-dadbod-ui
-- (~/.local/share/db_ui/connections.json) and generates the config sqls
-- expects in Neovim's state directory.
--
-- If you prefer to manage sqls by hand, create ~/.config/sqls/config.yml; it
-- takes precedence over the generated config.

local M = {}

local function read_json(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok or #lines == 0 then
		return nil
	end
	local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not decoded_ok or type(decoded) ~= "table" then
		return nil
	end
	return decoded
end

local function parse_db_url(url)
	local scheme, rest = url:match("^([%w+.-]+):(.*)$")
	if not scheme then
		return nil
	end

	local parsed = { scheme = scheme:lower() }
	if rest:sub(1, 2) ~= "//" then
		-- sqlite:relative/path.db and other opaque URLs
		parsed.opaque = vim.uri_decode(rest)
		return parsed
	end
	rest = rest:sub(3)

	rest = rest:gsub("#.*$", "")
	local query = rest:match("%?(.*)$")
	if query then
		parsed.query = query
		rest = rest:gsub("%?.*$", "")
	end

	-- Split at the last `@` so an unescaped @ in a password still works.
	local userinfo, host_path = rest:match("^(.+)@([^@]+)$")
	if userinfo then
		local user, password = userinfo:match("^([^:]*):(.*)$")
		if user == nil then
			user = userinfo
		end
		parsed.user = vim.uri_decode(user)
		parsed.password = password and vim.uri_decode(password) or nil
	else
		host_path = rest
	end

	local hostport, path = host_path:match("^([^/]*)(/.*)$")
	if not hostport then
		hostport, path = host_path, ""
	end

	-- IPv6 addresses are bracketed: [::1]:3306
	local host, port
	if hostport:sub(1, 1) == "[" then
		host, port = hostport:match("^%[([^%]]+)%]:(%d+)$")
		if not host then
			host = hostport:match("^%[([^%]]+)%]$")
		end
	else
		host, port = hostport:match("^(.+):(%d+)$")
		if not host then
			host = hostport
		end
	end

	parsed.host = host and vim.uri_decode(host) or nil
	parsed.port = port
	parsed.path = vim.uri_decode(path)
	return parsed
end

local function to_sqls_connection(conn, index)
	local url = type(conn) == "table" and conn.url or nil
	if type(url) ~= "string" then
		return nil
	end

	local parsed = parse_db_url(url)
	if not parsed then
		return nil
	end

	local alias = (type(conn) == "table" and conn.name) or ("db" .. index)
	local scheme = parsed.scheme

	if scheme == "mysql" or scheme == "mariadb" then
		local host = parsed.host or "127.0.0.1"
		local port = parsed.port or "3306"
		local db = (parsed.path or ""):gsub("^/", "")
		local auth = ""
		if parsed.user then
			auth = parsed.user
			if parsed.password then
				auth = auth .. ":" .. parsed.password
			end
			auth = auth .. "@"
		end
		-- go-sql-driver/mysql DSN: user:pass@tcp(host:port)/dbname
		local dsn = auth .. "tcp(" .. host .. ":" .. port .. ")/" .. db
		if parsed.query then
			dsn = dsn .. "?" .. parsed.query
		end
		return { alias = alias, driver = "mysql", dataSourceName = dsn }
	elseif scheme == "postgres" or scheme == "postgresql" then
		-- pgx accepts both postgres:// and postgresql:// URLs verbatim.
		return { alias = alias, driver = "postgresql", dataSourceName = url }
	elseif scheme == "sqlite" or scheme == "sqlite3" then
		local path = parsed.opaque or parsed.path
		if path and path ~= "" then
			return { alias = alias, driver = "sqlite3", dataSourceName = path }
		end
	elseif scheme == "sqlserver" or scheme == "mssql" then
		return { alias = alias, driver = "mssql", dataSourceName = url }
	end
end

function M.configure()
	local cmd = { "sqls" }

	local user_config = vim.fn.expand("~/.config/sqls/config.yml")
	if vim.fn.filereadable(user_config) == 1 then
		cmd = { "sqls", "-config", user_config }
	else
		local save_location = vim.g.db_ui_save_location
		if not save_location or save_location == "" then
			save_location = vim.fn.stdpath("data") .. "/db_ui"
		end
		local connections_file = vim.fn.expand(save_location) .. "/connections.json"
		local saved = read_json(connections_file)
		local connections = {}

		if type(saved) == "table" then
			for index, conn in ipairs(saved) do
				local converted = to_sqls_connection(conn, index)
				if converted then
					table.insert(connections, converted)
				end
			end
		end

		if #connections > 0 then
			local generated = vim.fn.stdpath("state") .. "/sqls/config.json"
			vim.fn.mkdir(vim.fs.dirname(generated), "p")
			-- Create the file with mode 0600 from the start: it contains
			-- database credentials.
			local fd = vim.uv.fs_open(generated, "w", 384)
			if fd then
				local payload = vim.json.encode({ lowercaseKeywords = false, connections = connections })
				vim.uv.fs_write(fd, payload, 0)
				vim.uv.fs_close(fd)
				cmd = { "sqls", "-config", generated }
			end
		end
	end

	vim.lsp.config("sqls", { cmd = cmd })
end

function M.setup()
	-- Treat common PostgreSQL dump/script extensions as SQL. There is no
	-- dedicated pgsql filetype in Vim, so generic SQL + sqls is the right fit.
	vim.filetype.add({
		extension = {
			pgsql = "sql",
			psql = "sql",
			postgres = "sql",
		},
	})

	vim.lsp.config("sqls", {
		filetypes = { "sql", "mysql", "plsql" },
		root_markers = { ".git", "config.yml", ".sqlsrc.yml" },
	})

	-- Runs before mason-lspconfig's vim.lsp.enable FileType handler, so sqls
	-- starts with the generated connection config instead of being restarted.
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "sql", "mysql", "plsql" },
		callback = M.configure,
	})
end

return M
