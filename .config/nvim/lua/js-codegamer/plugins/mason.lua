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
}
