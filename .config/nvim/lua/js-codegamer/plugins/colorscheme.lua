return {
  {
    'rose-pine/neovim',
    lazy = false,
    name = 'rose-pine',
    -- priority = 1000, -- Make sure to load this before all the other start plugins.
    -- init = function()
    --   vim.cmd.colorscheme 'rose-pine'
    -- end,
  },
  {
    'catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    -- priority = 1000, -- Make sure to load this before all the other start plugins.
    -- init = function()
    --   vim.cmd.colorscheme 'catppuccin-mocha'
    -- end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000, -- Make sure to load this before all the other start plugins.
    -- init = function()
    --   vim.cmd.colorscheme 'tokyonight'
    -- end,
  },
  {
    'helbing/aura.nvim',
    lazy = false,
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'aura'
    end,
  },
}
