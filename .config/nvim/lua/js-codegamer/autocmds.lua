-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

local mason_packages = {}

function AddPackages(pkgs)
  for k, v in pairs(pkgs) do
    if type(v) == 'string' then
      v = { v }
    end

    if not mason_packages[k] then
      mason_packages[k] = v
    else
      for _, vi in ipairs(v) do
        table.insert(mason_packages[k], vi)
      end
    end
  end
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('InstallTooling', { clear = true }),
  callback = function(args)
    local ft = args.match
    local tooling = require 'js-codegamer.tooling'

    local packages = tooling.GetMasonToolsForFT(ft)
    local starpkgs = tooling.GetMasonToolsForFT '*'
    if starpkgs then
      for _, pkg in ipairs(starpkgs) do
        table.insert(packages, pkg)
      end
    end
    if not packages then
      return
    end

    for _, pacakge in ipairs(packages) do
      local mason_registry = require 'mason-registry'
      local pkg = mason_registry.get_package(pacakge)
      if not pkg:is_installed() then
        vim.notify('Installing pacakge for ' .. ft .. ': ' .. pacakge, vim.log.levels.INFO)
        pkg:install()
      end
    end

    local server = tooling.filetype_to_server[ft]
    if server then
      require('lspconfig')[server].setup(tooling.registry.lsp[server])
    end
  end,
})
