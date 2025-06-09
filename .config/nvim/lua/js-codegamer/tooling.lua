-- tools.lua: Centralized management for LSP servers, formatters, and linters
local M = {}

-- Registry of all available tools by type
M.registry = {
  lsp = {
    -- Map from LSP server name to setup configuration
    -- These names must match those in nvim-lspconfig
    ast_grep = {},
    bashls = {},
    gopls = {},
    clangd = {},
    jsonls = {},
    ruff = {},
    rust_analyzer = {},
    ts_ls = {},
    html = {},
    cssls = {},
    marksman = {},
    yamlls = {},
    texlab = {},
    dockerls = {},
    lua_ls = {},
  },

  -- Map from formatter tool to configuration
  -- Only include standalone formatters not handled by LSP
  formatter = {
    stylua = {},
    prettierd = {},
    shfmt = {},
    ['clang-format'] = {},
    prettier = {},
    latexindent = {},
    goimports = {},
    gofumpt = {},
  },

  -- Map from linter tool to configuration
  -- Only include standalone linters not handled by LSP
  linter = {
    markdownlint = {},
    eslint_d = {},
    shellcheck = {},
    hadolint = {},
  },
}

-- Maps filetypes to LSP server names
M.filetype_to_server = {
  -- AST-grep for multiple languages
  ['*'] = 'ast_grep',
  -- Bash
  ['sh'] = 'bashls',
  ['bash'] = 'bashls',
  -- Go
  ['go'] = 'gopls',
  ['gomod'] = 'gopls',
  ['gowork'] = 'gopls',
  ['gotmpl'] = 'gopls',
  -- C/C++
  ['c'] = 'clangd',
  ['cpp'] = 'clangd',
  ['objc'] = 'clangd',
  ['objcpp'] = 'clangd',
  -- JSON
  ['json'] = 'jsonls',
  ['jsonc'] = 'jsonls',
  -- Python
  ['python'] = 'ruff',
  -- Rust
  ['rust'] = 'rust_analyzer',
  -- TypeScript/JavaScript
  ['typescript'] = 'ts_ls',
  ['javascript'] = 'ts_ls',
  ['typescriptreact'] = 'ts_ls',
  ['javascriptreact'] = 'ts_ls',
  ['jsx'] = 'ts_ls',
  ['tsx'] = 'ts_ls',
  -- HTML/CSS
  ['html'] = 'html',
  ['css'] = 'cssls',
  -- Markdown
  ['markdown'] = 'marksman',
  ['md'] = 'marksman',
  -- YAML
  ['yaml'] = 'yamlls',
  ['yml'] = 'yamlls',
  -- LaTeX
  ['tex'] = 'texlab',
  ['latex'] = 'texlab',
  -- Docker
  ['dockerfile'] = 'dockerls',
  -- Lua
  ['lua'] = 'lua_ls',
}

-- Maps filetypes to formatters
-- Only include standalone formatters not handled by LSP
M.filetype_to_formatter = {
  -- Lua
  ['lua'] = { 'stylua' },
  -- JavaScript/TypeScript
  ['javascript'] = { 'prettierd' },
  ['typescript'] = { 'prettierd' },
  ['typescriptreact'] = { 'prettierd' },
  ['javascriptreact'] = { 'prettierd' },
  ['html'] = { 'prettierd' },
  ['css'] = { 'prettierd' },
  ['jsx'] = { 'prettierd' },
  ['tsx'] = { 'prettierd' },
  -- Shell
  ['sh'] = { 'shfmt' },
  ['bash'] = { 'shfmt' },
  -- C/C++
  ['c'] = { 'clang-format' },
  ['cpp'] = { 'clang-format' },
  ['objc'] = { 'clang-format' },
  ['objcpp'] = { 'clang-format' },
  -- Markdown/YAML
  ['markdown'] = { 'prettier' },
  ['yaml'] = { 'prettier' },
  ['yml'] = { 'prettier' },
  -- LaTeX
  ['tex'] = { 'latexindent' },
  ['latex'] = { 'latexindent' },
  -- Go
  ['go'] = { 'goimports', 'gofumpt' },
  ['gomod'] = { 'goimports', 'gofumpt' },
  ['gowork'] = { 'goimports', 'gofumpt' },
}

-- Maps filetypes to linters
M.filetype_to_linter = {
  -- Markdown
  ['markdown'] = { 'markdownlint' },
  ['md'] = { 'markdownlint' },
  -- JavaScript/TypeScript
  ['javascript'] = { 'eslint_d' },
  ['typescript'] = { 'eslint_d' },
  ['javascriptreact'] = { 'eslint_d' },
  ['typescriptreact'] = { 'eslint_d' },
  ['jsx'] = { 'eslint_d' },
  ['tsx'] = { 'eslint_d' },
  -- Shell
  ['sh'] = { 'shellcheck' },
  ['bash'] = { 'shellcheck' },
  -- Dockerfile
  ['dockerfile'] = { 'hadolint' },
}

-- Mapping from tool names to Mason package names
M.tool_to_mason = {
  -- LSP Servers
  ast_grep = 'ast-grep',
  bashls = 'bash-language-server',
  jsonls = 'json-lsp',
  rust_analyzer = 'rust-analyzer',
  ts_ls = 'typescript-language-server',
  html = 'html-lsp',
  cssls = 'css-lsp',
  yamlls = 'yaml-language-server',
  dockerls = 'dockerfile-language-server',
  lua_ls = 'lua-language-server',
}

M.mason_exclude = {
  'rust-analyzer',
  'ast-grep',
  'clangd',
  'clang-format',
}

-- Get LSP servers with their configurations
function M.GetLSPServers()
  return vim.deepcopy(M.registry.lsp)
end

-- Get formatters for each filetype
function M.GetFormatters()
  return vim.deepcopy(M.filetype_to_formatter)
end

-- Get linters for each filetype
function M.GetLinters()
  return vim.deepcopy(M.filetype_to_linter)
end

local function subtract(table1, table2)
  local exclude_set = {}
  for _, value in ipairs(table2) do
    exclude_set[value] = true
  end

  local result = {}
  for _, value in ipairs(table1) do
    if not exclude_set[value] then
      table.insert(result, value)
    end
  end

  return result
end

-- Get all Mason tools required for a specific filetype
function M.GetMasonToolsForFT(filetype)
  local tools = {}

  -- Check if this filetype needs an LSP server
  local server = M.filetype_to_server[filetype]
  if server then
    local mason_name = M.tool_to_mason[server] or server
    table.insert(tools, mason_name)
  end

  -- Check for formatters
  local formatters = M.filetype_to_formatter[filetype]
  if formatters then
    for _, formatter in ipairs(formatters) do
      local mason_name = M.tool_to_mason[formatter] or formatter
      table.insert(tools, mason_name)
    end
  end

  -- Check for linters
  local linters = M.filetype_to_linter[filetype]
  if linters then
    for _, linter in ipairs(linters) do
      local mason_name = M.tool_to_mason[linter] or linter
      table.insert(tools, mason_name)
    end
  end

  tools = subtract(tools, M.mason_exclude)

  return tools
end

return M
