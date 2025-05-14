return {
  {
    'williamboman/mason.nvim',
    dependencies = 'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    },
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    name = 'mason-tool-installer',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    opts = {
      ensure_installed = { 'stylua' },
      auto_update = true,
      run_on_start = true,
    },
  },
}
