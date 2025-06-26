-- tools.lua: Centralized management for LSP servers, formatters, and linters
local M = {}

local lsp_settings = {
  pyright = {
    settings = {
      pyright = {
        disableOrganizeImports = true,
      },
      python = {
        analysis = {
          ignore = { '*' },
        },
      },
    },
  },
  ruff = {
    init_options = {
      settings = {
        logLevel = 'debug',
      },
    },
  },
}

-- Maps filetypes to LSP server names
local filetype_to_server = {
  -- AST-grep for multiple languages
  ['*'] = { 'ast_grep' },
  -- Bash
  ['sh'] = { 'bashls' },
  ['bash'] = { 'bashls' },
  -- Go
  ['go'] = { 'gopls' },
  ['gomod'] = { 'gopls' },
  ['gowork'] = { 'gopls' },
  ['gotmpl'] = { 'gopls' },
  -- C/C++
  ['c'] = { 'clangd' },
  ['cpp'] = { 'clangd' },
  ['objc'] = { 'clangd' },
  ['objcpp'] = { 'clangd' },
  -- JSON
  ['json'] = { 'jsonls' },
  ['jsonc'] = { 'jsonls' },
  -- Python
  ['python'] = { 'pyright', 'ruff' },
  -- Rust
  ['rust'] = { 'rust_analyzer' },
  -- TypeScript/JavaScript
  ['typescript'] = { 'ts_ls' },
  ['javascript'] = { 'ts_ls' },
  ['typescriptreact'] = { 'ts_ls' },
  ['javascriptreact'] = { 'ts_ls' },
  ['tsx'] = { 'ts_ls' },
  ['jsx'] = { 'ts_ls' },
  -- HTML/CSS
  ['html'] = { 'html' },
  ['css'] = { 'cssls' },
  -- Markdown
  ['markdown'] = { 'marksman' },
  ['md'] = { 'marksman' },
  -- YAML
  ['yaml'] = { 'yamlls' },
  ['yml'] = { 'yamlls' },
  -- LaTeX
  ['tex'] = { 'texlab' },
  ['latex'] = { 'texlab' },
  -- Docker
  ['dockerfile'] = { 'dockerls' },
  -- Lua
  ['lua'] = { 'lua_ls' },
  -- angular: comment when not using angular to use the defaults
  -- ['typescript'] = { 'angularls' },
  -- ['html'] = { 'angularls' },
  -- ['typescriptreact'] = { 'angularls' },
  -- ['tsx'] = { 'angularls' },
  -- ['htmlangular'] = { 'angularls' },
}

-- Maps filetypes to formatters
-- Only include standalone formatters not handled by LSP
local filetype_to_formatter = {
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
local filetype_to_linter = {
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
local tool_to_mason = {
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

local mason_exclude = {
  ['rust-analyzer'] = true,
  ['ast-grep'] = true,
  ['clangd'] = true,
  ['clang-format'] = true,
}

function M.GetLSPConfig(lsp)
  if lsp == nil then
    return vim.deepcopy(lsp_settings)
  else
    return vim.deepcopy(lsp_settings[lsp])
  end
end

-- Get LSP servers with their configurations
function M.GetLSPServers(filetype)
  if filetype == nil then
    return vim.deepcopy(filetype_to_server)
  else
    return filetype_to_server[filetype]
  end
end

-- Get formatters for each filetype
function M.GetFormatters(filetype)
  if filetype == nil then
    return vim.deepcopy(filetype_to_formatter)
  else
    return filetype_to_formatter[filetype]
  end
end

-- Get linters for each filetype
function M.GetLinters(filetype)
  if filetype == nil then
    return vim.deepcopy(filetype_to_linter)
  else
    return filetype_to_linter[filetype]
  end
end

-- Get all Mason tools required for a specific filetype
function M.GetMasonToolsForFT(filetype)
  local tools = {}

  local function register_to_tools(itools)
    itools = itools or {}
    for _, tool in ipairs(itools) do
      if not mason_exclude[tool] then
        table.insert(tools, tool_to_mason[tool] or tool)
      end
    end
  end

  register_to_tools(filetype_to_server[filetype])
  register_to_tools(filetype_to_formatter[filetype])
  register_to_tools(filetype_to_linter[filetype])

  return tools
end

return M
