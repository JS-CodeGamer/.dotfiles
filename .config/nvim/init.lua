-- install my config from github
local jspath = vim.fn.stdpath("config") .. "/lua/js"
if not vim.loop.fs_stat(jspath) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "https://github.com/JS-CodeGamer/nvim-config.git", jspath })
end

-- require my config
require("js.config")
