return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '▁' },
      topdelete = { text = '▔' },
      changedelete = { text = '▎' },
    },
    signcolumn = true,
    numhl = true,
    linehl = false,
    word_diff = false,
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      delay = 1000,
      ignore_whitespace = true,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    max_file_length = 40000,
    preview_config = {
      border = 'rounded',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1,
    },
    on_attach = function(bufnr)
      local gitsigns = require 'gitsigns'

      -- Helper function for more concise mapping definitions
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
          buffer = bufnr,
          desc = desc,
          silent = true,
          noremap = true,
        })
      end

      -- Navigation mappings
      map('n', ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gitsigns.next_hunk()
        end)
        return '<Ignore>'
      end, 'Jump to next git change')

      map('n', '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gitsigns.prev_hunk()
        end)
        return '<Ignore>'
      end, 'Jump to previous git change')

      -- Action mappings
      -- Visual mode
      map('v', '<leader>hs', function()
        gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Git stage selected hunk')

      map('v', '<leader>hr', function()
        gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, 'Git reset selected hunk')

      -- Normal mode - with consistent keybinding scheme
      map('n', '<leader>gs', gitsigns.stage_hunk, 'Git [S]tage hunk')
      map('n', '<leader>gr', gitsigns.reset_hunk, 'Git [R]eset hunk')
      map('n', '<leader>gS', gitsigns.stage_buffer, 'Git [S]tage buffer')
      map('n', '<leader>gu', gitsigns.undo_stage_hunk, 'Git [U]ndo stage hunk')
      map('n', '<leader>gR', gitsigns.reset_buffer, 'Git [R]eset buffer')
      map('n', '<leader>gp', gitsigns.preview_hunk, 'Git [P]review hunk')
      map('n', '<leader>gb', gitsigns.blame_line, 'Git [B]lame line')
      map('n', '<leader>gd', gitsigns.diffthis, 'Git [D]iff against index')
      map('n', '<leader>gD', function()
        gitsigns.diffthis '~'
      end, 'Git [D]iff against previous commit')
      map('n', '<leader>gB', function()
        gitsigns.blame_line { full = true }
      end, 'Git full [B]lame line')

      -- Toggle mappings - using a consistent prefix
      map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, 'Toggle git blame line')
      map('n', '<leader>gtd', gitsigns.toggle_deleted, 'Toggle git show deleted')
      map('n', '<leader>gth', gitsigns.toggle_linehl, 'Toggle git line highlight')
      map('n', '<leader>gtn', gitsigns.toggle_numhl, 'Toggle git number highlight')
      map('n', '<leader>gts', gitsigns.toggle_signs, 'Toggle git signs')
      map('n', '<leader>gtw', gitsigns.toggle_word_diff, 'Toggle git word diff')

      -- Other useful commands
      map('n', '<leader>gl', function()
        gitsigns.blame_line { full = false }
      end, 'Git show [L]ine blame')

      -- Text object mappings
      map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select git hunk')
      map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select git hunk')
    end,
  },
}
