-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

local options = {
  backup = false, -- creates a backup file
  breakindent = true, -- wrapped text starts with same indent
  clipboard = 'unnamedplus', -- allows neovim to access the system clipboard
  cmdheight = 2, -- more space in the neovim command line for displaying messages
  completeopt = { 'menuone', 'noselect' }, -- mostly just for cmp
  conceallevel = 0, -- so that `` is visible in markdown files
  fileencoding = 'utf-8', -- the encoding written to a file
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  mouse = 'a', -- allow the mouse to be used in neovim
  pumheight = 10, -- pop up menu height
  showmode = false, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 2, -- always show tabs
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go to the right of current window
  swapfile = false, -- creates a swapfile
  termguicolors = true, -- set term gui colors (most terminals support this)
  timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true, -- enable persistent undo
  updatetime = 250, -- faster completion (4000ms default)
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true, -- convert tabs to spaces
  shiftwidth = 2, -- the number of spaces inserted for each indentation
  tabstop = 2, -- insert 2 spaces for a tab
  cursorline = true, -- highlight the current line
  number = true, -- set numbered lines
  relativenumber = true, -- set relative numbered lines
  numberwidth = 2, -- set number column width to 2 {default 4}
  signcolumn = 'yes', -- always show the sign column, otherwise it would shift the text each time
  wrap = true,
  linebreak = true, -- companion to wrap, don't split words
  scrolloff = 10, -- is one of my fav
  sidescrolloff = 0,
  guifont = 'monospace:h17', -- the font used in graphical neovim applications
  virtualedit = 'block',
  inccommand = 'split',
  list = true,
  listchars = { tab = '» ', trail = '·', nbsp = '␣' },
}

vim.opt.shortmess:append 'c'

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.opt['whichwrap']:append '<,>,[,],h,l'
vim.opt['iskeyword']:append '-'
vim.opt['formatoptions']:remove 'c'
vim.opt['formatoptions']:remove 'r'
vim.opt['formatoptions']:remove 'o'


-- use c syntax for h files instead of cpp
vim.g.c_syntax_for_h = 1
