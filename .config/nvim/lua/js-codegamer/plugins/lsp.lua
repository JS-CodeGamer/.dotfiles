return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/lazydev.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    local lspconfig = require 'lspconfig'
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    local servers = require('js-codegamer.tooling').GetLSPServers()
    for server, conf in pairs(servers) do
      local server_config = {
        capabilities = capabilities,
      }

      if conf then
        server_config = vim.tbl_deep_extend('force', server_config, conf)
      end

      lspconfig[server].setup(server_config)
    end
  end,
}
