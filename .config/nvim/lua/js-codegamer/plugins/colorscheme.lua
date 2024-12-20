return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    -- priority = 1000, -- Make sure to load this before all the other start plugins.
    -- init = function()
    --   vim.cmd.colorscheme 'rose-pine'
    -- end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },
  {
    'folke/tokyonight.nvim',
    -- priority = 1000, -- Make sure to load this before all the other start plugins.
    -- init = function()
    --   vim.cmd.colorscheme 'tokyonight'
    -- end,
  },
}
