return {
  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth', event = 'VimEnter' },

  -- Comment support
  { 'numToStr/Comment.nvim', event = 'VimEnter' },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  -- Add indentation guides even on blank lines
  { 'lukas-reineke/indent-blankline.nvim', event = 'VimEnter', main = 'ibl', opts = {
    exclude = { filetypes = { 'dashboard' } },
  } },

  -- Rust Cargo.toml show latest version of deps
  { 'saecki/crates.nvim', event = { 'VimEnter Cargo.toml', 'BufEnter Cargo.toml' }, tag = 'stable', opts = {} },

  { 'nvim-tree/nvim-web-devicons', lazy = true },

  {
    'folke/which-key.nvim',
  },
}
