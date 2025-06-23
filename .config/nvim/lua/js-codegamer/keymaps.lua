-- WHICH-KEY GROUPS ---------------------
require('which-key').add {
  { '<leader>c', group = '[C]ode' },
  { '<leader>d', group = '[D]ocument / [D]ebug' },
  { '<leader>r', group = '[R]ename' },
  { '<leader>w', group = '[W]orkspace' },
  { '<leader>t', group = '[T]oggle' },
  { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  { '<leader>cp', group = '[CP]' },
  { '<leader>s', group = '[S]earch' },
}

local keymap = vim.keymap.set

-- GENERAL ------------------------------
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- WINDOW NAVIGATION --------------------
keymap('n', '<C-h>', '<C-w><C-h>', { desc = 'Move to left window' })
keymap('n', '<C-l>', '<C-w><C-l>', { desc = 'Move to right window' })
keymap('n', '<C-j>', '<C-w><C-j>', { desc = 'Move to lower window' })
keymap('n', '<C-k>', '<C-w><C-k>', { desc = 'Move to upper window' })

-- TAB NAVIGATION -----------------------
keymap('n', '<leader><Tab>', '<cmd>tabnext<CR>', { desc = 'Next tab' })
keymap('n', '<leader><S-Tab>', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })

-- NEOTREE ------------------------------
keymap('n', '<leader><leader>', ':Neotree toggle<CR>', { desc = 'NeoTree reveal' })
keymap('n', '<leader>tg', ':Neotree float git_status<CR>', { desc = '[T]oggle NeoTree [G]it view' })

-- DIAGNOSTICS --------------------------
keymap('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous [D]iagnostic' })
keymap('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next [D]iagnostic' })
keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror' })
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- LOCATION / QUICKFIX LIST NAV ---------
keymap('n', '[l', '<cmd>lprev<CR>', { desc = 'Previous [L]ocation item' })
keymap('n', ']l', '<cmd>lnext<CR>', { desc = 'Next [L]ocation item' })
keymap('n', '[q', '<cmd>cprev<CR>', { desc = 'Previous [Q]uickfix item' })
keymap('n', ']q', '<cmd>cnext<CR>', { desc = 'Next [Q]uickfix item' })
keymap('n', '<leader>lo', '<cmd>lopen<CR>', { desc = '[L]open location list' })
keymap('n', '<leader>lc', '<cmd>lclose<CR>', { desc = '[L]close location list' })
keymap('n', '<leader>co', '<cmd>copen<CR>', { desc = '[C]open quickfix list' })
keymap('n', '<leader>cc', '<cmd>cclose<CR>', { desc = '[C]close quickfix list' })

-- FORMAT -------------------------------
keymap('n', '<leader>f', function()
  require('conform').format { async = true }
end, { desc = '[F]ormat buffer' })

-- WHICH-KEY EXPAND: Search -------------
keymap('n', '<leader>sm', TBuiltin 'marks', { desc = '[S]earch [M]arks' })
keymap('n', '<leader>sc', TBuiltin 'commands', { desc = '[S]earch [C]ommands' })
keymap('n', '<leader>sC', TBuiltin 'command_history', { desc = '[S]earch [C]ommand History' })
keymap('n', '<leader>sh', TBuiltin 'help_tags', { desc = '[S]earch [H]elp' })
keymap('n', '<leader>sk', TBuiltin 'keymaps', { desc = '[S]earch [K]eymaps' })
keymap('n', '<leader>sf', TBuiltin 'find_files', { desc = '[S]earch [F]iles' })
keymap('n', '<leader>ss', TBuiltin 'builtin', { desc = '[S]elect Telescope [S]ource' })
keymap('n', '<leader>sw', TBuiltin 'grep_string', { desc = '[S]earch current [W]ord' })
keymap('n', '<leader>sg', TBuiltin 'live_grep', { desc = '[S]earch by [G]rep' })
keymap('n', '<leader>sd', TBuiltin 'diagnostics', { desc = '[S]earch [D]iagnostics' })
keymap('n', '<leader>sr', TBuiltin 'resume', { desc = '[S]earch [R]esume' })
keymap('n', '<leader>s.', TBuiltin 'oldfiles', { desc = '[S]earch Recent Files (.)' })
keymap('n', '<leader>sb', TBuiltin 'buffers', { desc = '[S]earch existing [B]uffers' })
keymap('n', '<leader>sn', TBuiltin('find_files', { cwd = vim.fn.stdpath 'config' }), { desc = '[S]earch [N]eovim config' })
keymap(
  'n',
  '<leader>s/',
  TBuiltin('live_grep', { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }),
  { desc = '[S]earch [/] in Open Buffers' }
)
keymap('n', '<leader>sl', TBuiltin 'loclist', { desc = '[S]earch [L]oclist' })
keymap('n', '<leader>sq', TBuiltin 'quickfix', { desc = '[S]earch [Q]uickfix List' })
keymap('n', '<leader>se', TBuiltin 'symbols', { desc = '[S]earch [E]moji/Symbols' })
keymap('n', '<leader>st', TBuiltin 'tags', { desc = '[S]earch [T]ags (All)' })
keymap('n', '<leader>sT', TBuiltin 'current_buffer_tags', { desc = '[S]earch [T]ags (Buffer)' })
keymap('n', '<leader>s?', function()
  themeopts = require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  }
  TBuiltin('current_buffer_fuzzy_find', themeopts)()
end, { desc = '[?] Fuzzy find in current buffer' })

-- CompetiTest
vim.keymap.set('n', '<leader>cprt', function()
  vim.cmd 'CompetiTest receive testcases'
end, { desc = '[CP]: [R]eceive [T]estcases' })

vim.keymap.set('n', '<leader>cprp', function()
  vim.cmd 'CompetiTest receive problem'
end, { desc = '[CP]: [R]eceive [P]roblem' })

vim.keymap.set('n', '<leader>cpt', function()
  vim.cmd 'CompetiTest run'
end, { desc = '[CP]: Run [T]ests' })

vim.keymap.set('n', '<leader>cpa', function()
  vim.cmd 'CompetiTest add_testcase'
end, { desc = '[CP]: [A]dd Testcase' })

vim.keymap.set('n', '<leader>cpe', function()
  vim.cmd 'CompetiTest edit_testcase'
end, { desc = '[CP]: [E]dit Testcase' })

-- Gitsigns
local function gscall(name, opts)
  return function()
    require('gitsigns')[name](opts)
  end
end

keymap('n', ']c', function()
  if vim.wo.diff then
    return ']c'
  end
  vim.schedule(gscall('nav_hunk', 'next'))
  return '<Ignore>'
end, { expr = true, desc = 'Jump to next git change' })

keymap('n', '[c', function()
  if vim.wo.diff then
    return '[c'
  end
  vim.schedule(gscall('nav_hunk', 'prev'))
  return '<Ignore>'
end, { expr = true, desc = 'Jump to previous git change' })

keymap('n', '<leader>gs', gscall 'stage_hunk', { desc = 'Git [S]tage hunk' })
keymap('v', '<leader>hs', gscall('stage_hunk', { vim.fn.line '.', vim.fn.line 'v' }), { desc = 'Git stage selected hunk' })

keymap('n', '<leader>gr', gscall 'reset_hunk', { desc = 'Git [R]eset hunk' })
keymap('v', '<leader>hr', gscall('reset_hunk', { vim.fn.line '.', vim.fn.line 'v' }), { desc = 'Git reset selected hunk' })

keymap('n', '<leader>gS', gscall 'stage_buffer', { desc = 'Git [S]tage buffer' })
keymap('n', '<leader>gu', gscall 'undo_stage_hunk', { desc = 'Git [U]ndo stage hunk' })
keymap('n', '<leader>gR', gscall 'reset_buffer', { desc = 'Git [R]eset buffer' })
keymap('n', '<leader>gp', gscall 'preview_hunk', { desc = 'Git [P]review hunk' })
keymap('n', '<leader>gb', gscall 'blame_line', { desc = 'Git [B]lame line' })
keymap('n', '<leader>gB', gscall('blame_line', { full = true }), { desc = 'Git full [B]lame line' })

keymap('n', '<leader>gd', gscall 'diffthis', { desc = 'Git [D]iff against index' })
keymap('n', '<leader>gD', gscall('diffthis', '~'), { desc = 'Git [D]iff against previous commit' })

keymap('n', '<leader>gtb', gscall 'toggle_current_line_blame', { desc = 'Toggle git blame line' })
keymap('n', '<leader>gtd', gscall 'toggle_deleted', { desc = 'Toggle git show deleted' })
keymap('n', '<leader>gth', gscall 'toggle_linehl', { desc = 'Toggle git line highlight' })
keymap('n', '<leader>gtn', gscall 'toggle_numhl', { desc = 'Toggle git number highlight' })
keymap('n', '<leader>gts', gscall 'toggle_signs', { desc = 'Toggle git signs' })
keymap('n', '<leader>gtw', gscall 'toggle_word_diff', { desc = 'Toggle git word diff' })

keymap('n', '<leader>gl', gscall('blame_line', { full = false }), { desc = 'Git show [L]ine blame' })

keymap('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select git hunk' })
keymap('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select git hunk' })
