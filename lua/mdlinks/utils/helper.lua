---@module 'mdlinks.utils.helper'

local fn = vim.fn

local M = {}

function M.is_windows() return fn.has("win32") == 1 or fn.has("win64") == 1 end
function M.is_wsl() return fn.has("wsl") == 1 end
function M.to_win_sep(p) return (p:gsub("/", "\\")) end

-- Matches "E:/path/.." or "C:\path\.."
---@param s string
---@return boolean
function M.looks_windows_sep(s)
	return s:match("^[A-Za-z]:[\\/]")
end

-- Returns os-plattform represented as string
function M.get_platform()
  if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then return "windows" end
  if vim.fn.has("mac") == 1 then return "mac" end
  return "linux"
end

-- Returns buffer directory, cwd or nil
---@param bufnr integer
---@return string|nil
function M.get_buf_dir(bufnr)
	local p = vim.api.nvim_buf_get_name(bufnr)
	if p == "" then
		return vim.uv.cwd() or nil
	end
	return vim.fn.fnamemodify(p, ":p:h")
end

-- Join bade and relativ part of a path and returns absolute path
---@param base string
---@param rel string
---@return string
function M.join_to_absolute_path(base, rel)
	return vim.fn.fnamemodify(base .. "/" .. rel, ":p")
end

return M
