vim.api.nvim_create_user_command('FormatDisable', function(args)
  print 'disable format'
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.cmd.normal 'let g:disable_autoformat = v:true'
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})

vim.api.nvim_create_user_command('FormatEnable', function()
  vim.cmd.normal 'let g:disable_autoformat = v:false'
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})

return { -- Autoformat
  'stevearc/conform.nvim',
  lazy = false,
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = 'first', -- not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format', 'ruff_organize_imports', 'ruff_fix' },
      javascript = { 'eslint_d', { 'prettierd', 'prettier' } },
      sh = { 'shfmt' },
      rust = { 'rustfmt' },
      c = { 'clang-format' },
      go = { { 'gofumpt', 'gofmt' }, 'goimports' },
      ['*'] = { 'codespell' },
    },
  },
}
