return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },

  dependencies = {
    { 'j-hui/fidget.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp',
    'b0o/schemastore.nvim',
  },

  config = function()
    local tooling = require 'js-codegamer.tooling'

    -- =========================================================================
    -- Capabilities
    -- =========================================================================

    local capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      require('cmp_nvim_lsp').default_capabilities()
    )

    -- =========================================================================
    -- Global defaults for ALL servers
    -- =========================================================================

    vim.lsp.config('*', {
      capabilities = capabilities,
      root_markers = { '.git' },
    })

    -- =========================================================================
    -- Register server configs BEFORE enabling
    -- =========================================================================

    local configs = tooling.GetLSPConfig()

    for server, conf in pairs(configs) do
      conf.capabilities = vim.tbl_deep_extend(
        'force',
        {},
        capabilities,
        conf.capabilities or {}
      )

      vim.lsp.config(server, conf)
    end

    -- =========================================================================
    -- Collect enabled servers (deduplicated)
    -- =========================================================================

    local enabled = {}
    local seen = {}

    local server_info = tooling.GetLSPServers()

    for _, servers_ft in pairs(server_info) do
      for _, server in ipairs(servers_ft) do
        if not seen[server] then
          seen[server] = true
          table.insert(enabled, server)
        end
      end
    end

    -- =========================================================================
    -- Enable servers
    -- =========================================================================

    vim.lsp.enable(enabled)
  end,
}

