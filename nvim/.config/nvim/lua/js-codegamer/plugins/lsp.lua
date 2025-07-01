return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'folke/neoconf.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/lazydev.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp',
    'b0o/schemastore.nvim',
  },
  config = function()
    require('neoconf').setup()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
    vim.lsp.config('*', {
      capabilities,
      root_markers = { '.git' },
    })

    local servers = {}
    local tooling = require 'js-codegamer.tooling'
    local server_info = tooling.GetLSPServers()
    for _, servers_ft in pairs(server_info) do
      for _, server in ipairs(servers_ft) do
        table.insert(servers, server)
      end
    end

    vim.lsp.enable(servers)

    for serv, conf in pairs(tooling.GetLSPConfig()) do
      vim.lsp.config(serv, conf)
    end
  end,
}
