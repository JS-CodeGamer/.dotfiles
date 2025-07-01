return {
  'nvim-lua/plenary.nvim',
  'folke/which-key.nvim',

  { 'tpope/vim-sleuth', event = 'VimEnter' }, -- Detect tabstop and shiftwidth automatically

  { 'numToStr/Comment.nvim', event = 'VimEnter' }, -- Comment support

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', opts = { signs = false } },

  -- Rust Cargo.toml show latest version of deps -- Rust Cargo.toml show latest version of deps
  { 'saecki/crates.nvim', event = { 'VimEnter Cargo.toml', 'BufEnter Cargo.toml' }, tag = 'stable', opts = {} },

  { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    event = 'VimEnter',
    main = 'ibl',
    opts = {
      exclude = { filetypes = { 'dashboard' } },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
  },

  'MunifTanjim/nui.nvim', -- dep for neo-tree
  { 'nvim-neo-tree/neo-tree.nvim', version = '*', cmd = 'Neotree' },
}
