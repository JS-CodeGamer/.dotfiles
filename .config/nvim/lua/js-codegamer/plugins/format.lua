-- Create User Commands
vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.notify('Formatting disabled for current buffer', vim.log.levels.INFO)
    vim.b.autoformat = false
  else
    vim.notify('Formatting disabled globally', vim.log.levels.INFO)
    vim.g.autoformat = false
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})

vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.autoformat = true
  vim.g.autoformat = true
  vim.notify('Formatting enabled', vim.log.levels.INFO)
end, {
  desc = 'Enable autoformat-on-save',
})

return {
  'stevearc/conform.nvim',
  dependencies = {
    'williamboman/mason.nvim',
  },
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = function()
    local formatters = require('js-codegamer.tooling').GetFormatters()

    return {
      formatters_by_ft = formatters,
      default_format_opts = {
        lsp_format = 'first',
      },

      format_on_save = function()
        if vim.b.autoformat == false or vim.g.autoformat == false then
          return nil
        end
        return {
          timeout_ms = 500,
        }
      end,

      notify_on_error = false,
      notify_no_formatters = true,
    }
  end,
}
