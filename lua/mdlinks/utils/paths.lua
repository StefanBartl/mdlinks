---@module 'mdlinks.utils.paths'
--- Cross-platform open helpers.

local fn = vim.fn
local helper = require("mdlinks.utils.helper")

local M = {}

---@param rel string
---@return string
function M.normalize_path(rel)
	if helper.is_windows() and rel:match("^%a:[/\\]") then
		return rel
	end
	local p = rel:gsub("^~", fn.expand("~"))
	if p:match("^/") then
		return p
	end
	if helper.is_windows() and p:match("^\\") then
		local cur = fn.expand("%:p:h")
		local drive = cur:match("^(%a:)")
		if drive then
			return drive .. p
		end
	end
	local bufdir = fn.expand("%:p:h")
	return fn.fnamemodify(bufdir .. "/" .. p, ":p")
end

---@param kind "url"|"file"
---@return string|string[]
---@diagnostic disable-next-line unused-param: preparation
function M.detect_opener(kind)
	if fn.has("mac") == 1 or fn.has("macunix") == 1 then
		return "open"
	end
	if not helper.is_windows() and not helper.is_wsl() then
		return "xdg-open"
	end
	if helper.is_wsl() then
		if fn.executable("wslview") == 1 then
			return "wslview"
		end
		if fn.executable("powershell.exe") == 1 then
			return { "powershell.exe", "-NoProfile", "-Command", "Start-Process" }
		end
		return "xdg-open"
	end
	-- Windows native: proven default; works for URLs & files
	return { "cmd.exe", "/c", "start", "" }
end

--- Spawn detached process. Adds Windows quoting for cmd.exe start.
---@param argv string|string[]
---@param target string
---@return boolean,string|nil,integer|nil
function M.spawn(argv, target)
	local exe = (type(argv) == "string") and argv
		or (type(argv) == "table" and type(argv[1]) == "string" and argv[1] or nil)

	if not exe then
		return false, "Invalid opener argv (exe missing)", -1
	end
	if fn.executable(exe) ~= 1 then
		return false, ("Not executable: %q"):format(exe), -1
	end

	local cmd
	if type(argv) == "string" then
		cmd = { exe, target }
	else
		cmd = vim.deepcopy(argv)
		local is_cmd = exe:lower():find("cmd%.exe$", 1, true) ~= nil
		if is_cmd then
			for i = 1, #cmd do
				if type(cmd[i]) == "string" and cmd[i]:lower() == "start" then
					if cmd[i + 1] ~= "" then
						table.insert(cmd, i + 1, "")
					end
					break
				end
			end
			if not (target:match("^%a+://") or target:match("^mailto:")) then
				local winp = helper.to_win_sep(target)
				target = '"' .. winp .. '"'
			end
		end
		table.insert(cmd, target)
	end

	local job = fn.jobstart(cmd, { detach = true })
	if job <= 0 then
		return false, ("jobstart failed (argv: %s)"):format(vim.inspect(cmd)), job
	end
	return true, nil, job
end

return M
