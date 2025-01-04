vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    print 'disabling formatting for this buffer'
    vim.b['autoformat'] = false
  else
    print 'disabling formatting'
    vim.g['autoformat'] = false
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})

vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b['autoformat'] = true
  vim.g['autoformat'] = true
end, {
  desc = 'Enable autoformat-on-save',
})

local js_ecosystem = function(bufnr)
  local formatters = {
    'eslint_d',
  }
  if require('conform').get_formatter_info('prettierd', bufnr).available then
    table.insert(formatters, 'prettierd')
  else
    table.insert(formatters, 'prettier')
  end
  return formatters
end

return { -- Autoformat
  'zapling/mason-conform.nvim',
  dependencies = {
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
      formatters_by_ft = {
        lua = { 'stylua' },
        python = function(bufnr)
          if require('conform').get_formatter_info('ruff_format', bufnr).available then
            return { 'ruff_format', 'ruff_organize_imports', 'ruff_fix' }
          else
            return { 'isort', 'black' }
          end
        end,
        javascript = function(bufnr)
          return js_ecosystem(bufnr)
        end,
        typescript = function(bufnr)
          return js_ecosystem(bufnr)
        end,
        typescriptreact = function(bufnr)
          return js_ecosystem(bufnr)
        end,
        sh = { 'shfmt' },
        rust = { 'rustfmt' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        go = function(bufnr)
          local formatters = { 'goimports' }
          if require('conform').get_formatter_info('gofumpt', bufnr).available then
            table.insert(formatters, 1, 'gofumpt')
          else
            table.insert(formatters, 1, 'gofmt')
          end
          return formatters
        end,
      },
      default_format_opts = {
        lsp_format = 'first',
      },
      format_on_save = function()
        if vim.b['autoformat'] == false or vim.g['autoformat'] == false then
          return false
        end
        return {
          timeout_ms = 500,
        }
      end,
      notify_on_error = false,
      notify_no_formatters = true,
    },
  },
}
