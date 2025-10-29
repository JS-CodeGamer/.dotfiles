vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local function createLSPHighlight(event)
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

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

    local map = function(keys, func, desc, method_str)
      if not method_str or client:supports_method(method_str) then
        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end
    end

    local builtin = require 'telescope.builtin'

    -- Definitions / references / declarations
    map('gd', builtin.lsp_definitions, '[G]oto [D]efinition', 'textDocument/definition')
    map('gr', builtin.lsp_references, '[G]oto [R]eferences', 'textDocument/references')
    map('gI', builtin.lsp_implementations, '[G]oto [I]mplementation', 'textDocument/implementation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration', 'textDocument/declaration')

    -- Type info
    map('<leader>D', builtin.lsp_type_definitions, 'Type [D]efinition', 'textDocument/typeDefinition')

    -- Symbols
    map('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols', 'textDocument/documentSymbol')
    map('<leader>ws', builtin.lsp_workspace_symbols, '[W]orkspace [S]ymbols', 'workspace/symbol')

    -- Code actions / rename
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame', 'textDocument/rename')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', 'textDocument/codeAction')

    -- Hover / signature help
    map('<C-k>', vim.lsp.buf.signature_help, 'Signature Help', 'textDocument/signatureHelp')

    -- Code lens
    map('<leader>cl', vim.lsp.codelens.run, '[C]ode [L]ens', 'textDocument/codeLens')

    -- Call hierarchy
    map('<leader>ci', vim.lsp.buf.incoming_calls, 'Call [I]ncoming', 'callHierarchy/incomingCalls')
    map('<leader>co', vim.lsp.buf.outgoing_calls, 'Call [O]utgoing', 'callHierarchy/outgoingCalls')

    -- Toggle inlay hints
    if client:supports_method 'textDocument/inlayHint' then
      vim.lsp.inlay_hint.enable(true)
    end
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, '[T]oggle Inlay [H]ints', 'textDocument/inlayHint')

    -- Highlights
    if client:supports_method 'textDocument/documentHighlight' then
      createLSPHighlight(event)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('InstallTooling', { clear = true }),
  callback = function(args)
    local ft = args.match

    local tooling = require 'js-codegamer.tooling'
    local ok, mason_registry = pcall(require, 'mason-registry')

    local packages = tooling.GetMasonToolsForFT(ft)
    for _, pkg in ipairs(tooling.GetMasonToolsForFT '*') do
      table.insert(packages, pkg)
    end
    if not (ok and packages) then
      return
    end

    for _, pacakge in ipairs(packages) do
      local pkg = mason_registry.get_package(pacakge)
      if not (pkg:is_installed() or pkg:is_installing()) then
        pkg:install()
      end
    end
  end,
})

-- Auto Execute code actions on save
local tooling = require 'js-codegamer.tooling'
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('PreWriteTooling', { clear = true }),
  callback = function(event)
    for _, client in ipairs(vim.lsp.get_clients { bufnr = event.buf }) do
      local actions = tooling.GetLspActionToExec(client.name)
      if actions and #actions > 0 then
        for _, action in ipairs(actions) do
          vim.lsp.buf.code_action {
            ---@diagnostic disable-next-line: missing-fields
            context = { only = { action } },
            apply = true,
          }
          vim.wait(100)
        end
      end
    end

    -- Now format using conform.nvim
    if not (vim.b.autoformat == false or vim.g.autoformat == false) then
      require('conform').format { timeout_ms = 5000 }
    end
  end,
})

vim.api.nvim_create_autocmd('BufRead', {
  callback = function()
    vim.cmd 'normal zR'
  end,
})
