-- vim: ts=2 sts=2 sw=2 et

-- [[ Load options ]]
require 'js-codegamer.options'
-- [[ Load autocommands ]]
require 'js-codegamer.autocmds'

-- [[ Install `lazy.nvim` plugin manager if not exists ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
--- @diagnostic disable-next-line: undefined-field
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
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup {
  spec = {
    { import = 'js-codegamer.plugins' },
  },
  defaults = {
    lazy = true,
    version = false,
  },
  install = { missing = true, colorscheme = { 'tokyonight' } },
  checker = { enabled = true, frequency = 24 * 60 * 60 },
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

-- [[ Load keymaps ]]
require 'js-codegamer.keymaps'
