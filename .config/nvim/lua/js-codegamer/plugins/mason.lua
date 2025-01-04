return {
  {
    'williamboman/mason.nvim',
    name = 'mason',
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
      'mason',
      'mason-lspconfig',
      'mason-nvim-dap',
    },
    opts = {
      ensure_installed = { 'stylua' },
      auto_update = true,
      run_on_start = true,
    },
  },
}
