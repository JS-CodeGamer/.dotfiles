-- vim: ts=2 sts=2 sw=2 et

-- NOTE: Load options
require 'js-codegamer.options'
-- NOTE: Load autocommands
require 'js-codegamer.autocmds'

-- [[ Install `lazy.nvim` plugin manager if not exists ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup {
  spec = {
    { import = 'js-codegamer.plugins' },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  checker = { enabled = true },
  profiling = { loader = true },
  ui = {
    -- Set vim.g.have_nerd_font or use sensible unicode icons
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}
