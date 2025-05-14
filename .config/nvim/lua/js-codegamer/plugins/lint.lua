return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    -- Define linters by filetype
    local linters = require('js-codegamer.tooling').GetLinters()
    lint.linters_by_ft = linters

    -- Configure eslint_d
    lint.linters.eslint_d.args = {
      '--format=json',
      '--no-warn-ignored',
      '--stdin',
      '--stdin-filename',
      function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    -- Custom debounce implementation
    local debounce_timers = {}
    local function debounced_lint(delay)
      local bufnr = vim.api.nvim_get_current_buf()
      local timer = debounce_timers[bufnr]

      if timer then
        timer:stop()
      end

      debounce_timers[bufnr] = vim.defer_fn(function()
        -- Skip large files and non-file buffers
        if vim.fn.getfsize(vim.api.nvim_buf_get_name(0)) > 1000000 or vim.bo.buftype ~= '' then
          return
        end

        if vim.api.nvim_buf_is_valid(bufnr) then
          lint.try_lint()
        end

        debounce_timers[bufnr] = nil
      end, delay)
    end

    -- Create autocommands for linting
    local lint_augroup = vim.api.nvim_create_augroup('NvimLint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        debounced_lint(300)
      end,
    })

    vim.api.nvim_create_autocmd({ 'TextChanged' }, {
      group = lint_augroup,
      callback = function()
        debounced_lint(1000)
      end,
    })

    -- Create keymaps for manual linting
    vim.keymap.set('n', '<leader>ll', function()
      lint.try_lint()
    end, { desc = 'Lint current file' })
  end,
}
