---@module 'plugin/mdlinks'
-- Runtime entrypoint

if vim.g.loaded_mdlinks then
  return
end
vim.g.loaded_mdlinks = true

local ok, commands = pcall(require, "mdlinks.commands")
if ok and type(commands.register_user_commands) == "function" then
  commands.register_user_commands()
else
    vim.schedule(function()
    vim.notify("[mdlinks] commands module not available", vim.log.levels.ERROR)
  end)
end
