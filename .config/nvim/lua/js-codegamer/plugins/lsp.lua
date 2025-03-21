local servers = {
  ast_grep = {},
  bashls = {},
  gopls = {},
  clangd = {},
  jsonls = {},
  jedi_language_server = {},
  rust_analyzer = {},
  ts_ls = {},
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
      },
    },
  },
}

return { -- LSP Configuration & Plugins
  'williamboman/mason-lspconfig.nvim',
  name = 'mason-lspconfig',
  dependencies = {
    'neovim/nvim-lspconfig',
    'mason',
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/lazydev.nvim', opts = {} },
  },
  opts = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    return {
      ensure_installed = servers,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}

          --  Extend nvim lsp capabilities with nvim cmp
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
