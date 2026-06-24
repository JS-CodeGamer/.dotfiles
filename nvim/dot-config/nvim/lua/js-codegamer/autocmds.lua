-- ============================================================================
-- Autocommands Configuration
-- ============================================================================

-- General UI/UX Autocommands
local general_group = vim.api.nvim_create_augroup('general-ui', { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = general_group,
  callback = function()
    vim.highlight.on_yank { timeout = 200 }
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Auto-resize splits on window resize',
  group = general_group,
  callback = function()
    vim.cmd 'wincmd ='
  end,
})

-- Check if we need to reload the file when it gains focus
vim.api.nvim_create_autocmd('FocusGained', {
  desc = 'Check if file needs reload on focus gain',
  group = general_group,
  callback = function()
    if vim.bo.modifiable and not vim.bo.readonly then
      vim.cmd 'checktime'
    end
  end,
})

-- Hide cursor in inactive windows
vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  desc = 'Hide cursor in inactive windows',
  group = general_group,
  callback = function()
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
  end,
})

-- Show cursor in active windows
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  desc = 'Show cursor in active windows',
  group = general_group,
  callback = function()
    if vim.bo.filetype ~= 'NvimTree' then
      vim.opt_local.cursorline = true
    end
  end,
})

-- ============================================================================
-- LSP Configuration
-- ============================================================================

--- Creates LSP document highlight autocommands
---@param event table The LSP attach event
local function create_lsp_highlight(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if not client or not client.supports_method 'textDocument/documentHighlight' then
    return
  end

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
    buffer = event.buf,
    group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
    callback = function(detach_event)
      vim.lsp.buf.clear_references()
      vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = detach_event.buf }
    end,
  })
end

--- Sets up LSP keymaps for the current buffer
---@param event table The LSP attach event
---@param client table The LSP client
local function setup_lsp_keymaps(event, client)
  local map = function(keys, func, desc, method_str)
    if not method_str or client.supports_method(method_str) then
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
  map('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols', 'workspace/symbol')

  -- Code actions / rename
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame', 'textDocument/rename')
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', 'textDocument/codeAction')

  -- Hover / signature help
  map('K', vim.lsp.buf.hover, 'Hover Documentation', 'textDocument/hover')
  map('<C-k>', vim.lsp.buf.signature_help, 'Signature Help', 'textDocument/signatureHelp')

  -- Code lens
  map('<leader>cl', vim.lsp.codelens.run, '[C]ode [L]ens', 'textDocument/codeLens')

  -- Call hierarchy
  map('<leader>ci', vim.lsp.buf.incoming_calls, '[C]all [I]ncoming', 'callHierarchy/incomingCalls')
  map('<leader>co', vim.lsp.buf.outgoing_calls, '[C]all [O]utgoing', 'callHierarchy/outgoingCalls')

  -- Toggle inlay hints
  map('<leader>th', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
  end, '[T]oggle Inlay [H]ints', 'textDocument/inlayHint')
end

-- LSP Attach handler
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    -- Setup keymaps
    setup_lsp_keymaps(event, client)

    -- Enable inlay hints if supported
    if client.supports_method 'textDocument/inlayHint' then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    end

    -- Setup document highlighting
    create_lsp_highlight(event)
  end,
})

-- ============================================================================
-- Mason Tooling Auto-Install
-- ============================================================================

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('mason-auto-install', { clear = true }),
  callback = function(args)
    local ok, tooling = pcall(require, 'js-codegamer.tooling')
    if not ok then
      return
    end

    local ok_registry, mason_registry = pcall(require, 'mason-registry')
    if not ok_registry then
      return
    end

    -- Collect packages for this filetype
    local packages = {}
    vim.list_extend(packages, tooling.GetMasonToolsForFT(args.match) or {})
    vim.list_extend(packages, tooling.GetMasonToolsForFT '*' or {})

    if #packages == 0 then
      return
    end

    -- Install missing packages
    for _, package_name in ipairs(packages) do
      local ok_pkg, pkg = pcall(mason_registry.get_package, package_name)
      if ok_pkg and pkg and not (pkg:is_installed() or pkg:is_installing()) then
        vim.notify('Installing ' .. package_name, vim.log.levels.INFO)
        pkg:install()
      end
    end
  end,
})

-- ============================================================================
-- Format and Code Actions on Save
-- ============================================================================

vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('format-on-save', { clear = true }),
  callback = function(event)
    -- Skip if autoformat is disabled
    if vim.b[event.buf].autoformat == false or vim.g.autoformat == false then
      return
    end

    -- Execute LSP code actions
    local ok_tooling, tooling = pcall(require, 'js-codegamer.tooling')
    if ok_tooling then
      for _, client in ipairs(vim.lsp.get_clients { bufnr = event.buf }) do
        local actions = tooling.GetLspActionToExec(client.name)
        if actions and #actions > 0 then
          for _, action in ipairs(actions) do
            vim.lsp.buf.code_action {
              context = { only = { action }, diagnostics = {} },
              apply = true,
            }
            vim.wait(100)
          end
        end
      end
    end

    -- Format using conform.nvim
    local ok_conform, conform = pcall(require, 'conform')
    if ok_conform then
      conform.format {
        timeout_ms = 5000,
        lsp_fallback = true,
        bufnr = event.buf,
      }
    end
  end,
})

-- ============================================================================
-- File Opening Behavior
-- ============================================================================

local file_group = vim.api.nvim_create_augroup('file-behavior', { clear = true })

-- Open all folds when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = file_group,
  desc = 'Open all folds when reading a file',
  callback = function()
    if vim.opt_local.foldmethod:get() ~= 'manual' then
      vim.cmd 'normal! zR'
    end
  end,
})

-- Restore cursor position when opening a file
vim.api.nvim_create_autocmd('BufReadPost', {
  group = file_group,
  desc = 'Restore cursor position when opening a file',
  callback = function(event)
    local exclude_ft = { 'gitcommit', 'commit', 'gitrebase', 'fugitive' }
    if vim.tbl_contains(exclude_ft, vim.bo[event.buf].filetype) then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Set file-specific options
vim.api.nvim_create_autocmd('FileType', {
  group = file_group,
  desc = 'Set file-specific options',
  callback = function(args)
    local ft = args.match

    -- Filetype-specific settings
    if ft == 'python' then
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
    elseif ft == 'javascript' or ft == 'typescript' or ft == 'json' then
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
    elseif ft == 'go' then
      vim.opt_local.expandtab = false
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
    elseif ft == 'yaml' or ft == 'yml' then
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
    elseif ft == 'markdown' then
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      vim.opt_local.conceallevel = 2
    elseif ft == 'gitcommit' then
      vim.opt_local.spell = true
      vim.opt_local.textwidth = 72
    end
  end,
})

-- Auto-create directories when saving
vim.api.nvim_create_autocmd('BufWritePre', {
  group = file_group,
  desc = "Auto-create parent directories if they don't exist",
  callback = function(event)
    local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(event.buf), ':h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- ============================================================================
-- Terminal Behavior
-- ============================================================================

local terminal_group = vim.api.nvim_create_augroup('terminal-behavior', { clear = true })

vim.api.nvim_create_autocmd('TermOpen', {
  group = terminal_group,
  desc = 'Configure terminal settings',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
    vim.opt_local.signcolumn = 'no'
    vim.cmd 'startinsert'
  end,
})

-- Enter terminal mode when entering terminal buffer
vim.api.nvim_create_autocmd('BufEnter', {
  group = terminal_group,
  desc = 'Enter terminal mode when entering terminal buffer',
  callback = function()
    if vim.bo.buftype == 'terminal' then
      vim.cmd 'startinsert'
    end
  end,
})

-- Leave terminal mode when leaving terminal buffer
vim.api.nvim_create_autocmd('BufLeave', {
  group = terminal_group,
  desc = 'Leave terminal mode when leaving terminal buffer',
  callback = function()
    if vim.bo.buftype == 'terminal' then
      vim.cmd 'stopinsert'
    end
  end,
})

-- ============================================================================
-- Code Quality and Cleanup
-- ============================================================================

local cleanup_group = vim.api.nvim_create_augroup('code-cleanup', { clear = true })

-- Remove trailing whitespace on save (configurable)
vim.api.nvim_create_autocmd('BufWritePre', {
  group = cleanup_group,
  desc = 'Remove trailing whitespace on save',
  callback = function(event)
    -- Skip for certain filetypes
    local exclude_ft = { 'markdown', 'text', 'gitcommit', 'diff' }
    if vim.tbl_contains(exclude_ft, vim.bo[event.buf].filetype) then
      return
    end

    -- Skip if disabled via buffer variable
    if vim.b[event.buf].trim_whitespace == false or vim.g.trim_whitespace == false then
      return
    end

    local save_cursor = vim.fn.getpos '.'
    vim.cmd [[silent! %s/\s\+$//e]]
    vim.fn.setpos('.', save_cursor)
  end,
})

-- ============================================================================
-- Quickfix and Location List Management
-- ============================================================================

local quickfix_group = vim.api.nvim_create_augroup('quickfix-management', { clear = true })

-- Auto-open quickfix if there are errors
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = quickfix_group,
  desc = 'Auto-open quickfix window if there are errors',
  callback = function()
    local qf_list = vim.fn.getqflist()
    if #qf_list > 0 then
      vim.cmd 'copen'
    end
  end,
})

-- Close quickfix/loclist when going to last window
vim.api.nvim_create_autocmd('WinEnter', {
  group = quickfix_group,
  desc = 'Close quickfix/loclist when going to last window',
  callback = function()
    if vim.fn.winnr '$' == 1 and vim.bo.buftype == 'quickfix' then
      vim.cmd 'quit'
    end
  end,
})

-- ============================================================================
-- Performance Optimizations
-- ============================================================================

local performance_group = vim.api.nvim_create_augroup('performance-optimizations', { clear = true })

-- Disable syntax highlighting for very large files
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = performance_group,
  desc = 'Disable syntax highlighting for very large files',
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, args.file)
    if ok and stats and stats.size > 1024 * 1024 then -- 1MB
      vim.cmd 'syntax off'
      vim.b[args.buf].large_file = true
    end
  end,
})

-- Disable certain features for large files
vim.api.nvim_create_autocmd('BufReadPost', {
  group = performance_group,
  desc = 'Disable features for large files',
  callback = function(args)
    if vim.b[args.buf].large_file then
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.buflisted = false
    end
  end,
})

