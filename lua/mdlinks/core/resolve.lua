---@module 'mdlinks.resolve'

local M = {}

local helper = require("mdlinks.utils.helper")

---@param bufnr integer
---@param link MdLink
---@return Resolved|nil
function M.resolve(bufnr, link)
	if type(link) ~= "table" then
		return nil
	end

	if link.kind == "url" then
		return { kind = "url", url = link.target }
	elseif link.kind == "heading" then
		-- Normalize "##test" / "## test"
		local hashes, text = link.target:match("^%s*(#+)%s*(.*)$")
		local level = hashes and #hashes or 1
		text = (text or ""):gsub("%s+$", "")
		return { kind = "heading", heading = { level = level, text = text } }
	else
		local t = link.target
		-- Strip surrounding quotes for paths like ("./foo bar.pdf")
		t = (t:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1"))

		local path
		if helper.looks_windows_sep(t) or t:match("^/") or t:match("^~[/\\]") then
			path = vim.fn.fnamemodify(t, ":p")
		else
			local safe_buf_dir = helper.get_buf_dir(bufnr)
			if safe_buf_dir then
				path = helper.join_to_absolute_path(safe_buf_dir, t)
            else
                vim.notify("[mdlink] no absolut path or cwd for this buffer resovable", 4)
                return nil
			end
		end
		return { kind = link.kind, path = path }
	end
end

return M
