-- Utility Function
local telescope_builtin = function(builtin_name, opts)
  return function()
    require('telescope.builtin')[builtin_name](opts or {})
  end
end

require('which-key').add { -- Top level groups
  { '<leader>c', group = '[C]ode' },
  { '<leader>d', group = '[D]ocument / [D]ebug' },
  { '<leader>r', group = '[R]ename' },
  { '<leader>w', group = '[W]orkspace' },
  { '<leader>t', group = '[T]oggle' },
  { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  { '<leader>cp', group = 'C[P]' },

  -- Search Group with nested mappings
  {
    '<leader>s',
    group = '[S]earch',
    expand = function()
      return {
        { 'm', telescope_builtin 'marks', desc = '[S]earch [M]arks' },
        { 'c', telescope_builtin 'commands', desc = '[S]earch [C]ommands' },
        { 'C', telescope_builtin 'command_history', desc = '[S]earch [C]ommand History' },
        { 'h', telescope_builtin 'help_tags', desc = '[S]earch [H]elp' },
        { 'k', telescope_builtin 'keymaps', desc = '[S]earch [K]eymaps' },
        { 'f', telescope_builtin 'find_files', desc = '[S]earch [F]iles' },
        { 's', telescope_builtin 'builtin', desc = '[S]elect Telescope [S]ource' },
        { 'w', telescope_builtin 'grep_string', desc = '[S]earch current [W]ord' },
        { 'g', telescope_builtin 'live_grep', desc = '[S]earch by [G]rep' },
        { 'd', telescope_builtin 'diagnostics', desc = '[S]earch [D]iagnostics' },
        { 'r', telescope_builtin 'resume', desc = '[S]earch [R]esume' },
        { '.', telescope_builtin 'oldfiles', desc = '[S]earch Recent Files (.)' },
        { 'b', telescope_builtin 'buffers', desc = '[S]earch existing [B]uffers' },
        {
          'n',
          telescope_builtin('find_files', { cwd = vim.fn.stdpath 'config' }),
          desc = '[S]earch [N]eovim config',
        },
        {
          '/',
          telescope_builtin('live_grep', { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }),
          desc = '[S]earch [/] in Open Buffers',
        },
        { 'l', telescope_builtin 'loclist', desc = '[S]earch [L]oclist' },
        { 'q', telescope_builtin 'quickfix', desc = '[S]earch [Q]uickfix List' },
        { 'e', telescope_builtin 'symbols', desc = '[S]earch [E]moji/Symbols' },
        { 't', telescope_builtin 'tags', desc = '[S]earch [T]ags (All)' },
        { 'T', telescope_builtin 'current_buffer_tags', desc = '[S]earch [T]ags (Buffer)' },
        {
          '?',
          function()
            require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
              winblend = 10,
              previewer = false,
            })
          end,
          desc = '[?] Fuzzy find in current buffer',
        },
      }
    end,
  },

  -- CompetiTest nested group
  {
    '<leader>cp',
    group = '[CP]',
    expand = function()
      return {
        {
          'r',
          group = '[CP]: [R]eceive',
          expand = function()
            return {
              {
                't',
                function()
                  vim.cmd 'CompetiTest receive testcases'
                end,
                desc = 'CompetiTest: receive testcases',
              },
              {
                'p',
                function()
                  vim.cmd 'CompetiTest receive problem'
                end,
                desc = 'CompetiTest: receive problem',
              },
            }
          end,
        },
        {
          't',
          function()
            vim.cmd 'CompetiTest run'
          end,
          desc = 'CompetiTest: run testcases',
        },
        {
          'a',
          function()
            vim.cmd 'CompetiTest add_testcase'
          end,
          desc = 'CompetiTest: add testcase',
        },
        {
          'e',
          function()
            vim.cmd 'CompetiTest edit_testcase'
          end,
          desc = 'CompetiTest: edit testcase',
        },
      }
    end,
  },

  -- Format
  {
    '<leader>f',
    function()
      require('conform').format { async = true, lsp_fallback = true }
    end,
    desc = '[F]ormat buffer',
  },
}

-- Set regular keymaps with vim.keymap.set
-- NeoTree
vim.keymap.set('n', '<leader><leader>', ':Neotree toggle<CR>', { desc = 'NeoTree reveal' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous [D]iagnostic' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next [D]iagnostic' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Search highlight and terminal
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move to right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move to upper window' })

-- Tab navigation
vim.keymap.set('n', '<leader><Tab>', '<cmd>tabnext<CR>', { desc = 'Next tab' })
vim.keymap.set('n', '<leader><S-Tab>', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })
