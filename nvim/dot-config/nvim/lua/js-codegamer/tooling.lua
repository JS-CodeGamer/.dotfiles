-- tools.lua: Centralized management for LSP servers, formatters, and linters
local cjson_imported, cjson = pcall(require, 'cjson')

local config_path = vim.fn.stdpath 'config' .. '/tools.jsonc'

local data = {}
if cjson_imported then
  local file = io.open(config_path, 'r')
  if not file then
    vim.print('Failed to read: ' .. path)
  end
  local content = ''
  for line in file:lines() do
    local comment_loc = line:find '//'
    if comment_loc then
      line = line:sub(0, comment_loc - 1)
    end
    -- remove comments
    content = content .. line
  end
  file:close()
  local ok, _data = pcall(cjson.decode, content)
  if not ok then
    vim.print('Failed to decode JSON: ' .. parsed)
  else
    data = _data
  end
end

local filetypes = {}
local filetype_to_server = {}
local filetype_to_formatter = {}
local filetype_to_linter = {}
local tool_to_mason = {}
local mason_exclude = {}
local lsp_actions_autoexec = {}
local lsp_settings_ = {}

if cjson_imported then
  for ft, ft_data in pairs(data.tools or {}) do
    if not vim.tbl_contains({ '*' }, ft) then
      table.insert(filetypes, ft)
    end

    if ft_data['lsp-server'] then
      filetype_to_server[ft] = ft_data['lsp-server']
    end
    if ft_data['formatter'] then
      filetype_to_formatter[ft] = ft_data['formatter']
    end
    if ft_data['linter'] then
      filetype_to_linter[ft] = ft_data['linter']
    end
  end

  tool_to_mason = data['tool-to-mason'] or {}
  mason_exclude = data['mason-exclude'] or {}
  lsp_actions_autoexec = data['lsp-action-autoexec'] or {}

  lsp_settings_ = data['lsp-settings'] or {}
end

local function lsp_settings()
  local dynamic_settings = {
    jsonls = {
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
          validate = {
            enable = true,
          },
        },
      },
    },
  }
  vim.tbl_deep_extend('force', lsp_settings_, dynamic_settings)
  return lsp_settings_
end

local M = {}

function M.GetLSPConfig(lsp)
  if lsp == nil then
    return vim.deepcopy(lsp_settings())
  else
    return vim.deepcopy(lsp_settings()[lsp])
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

function M.getTSFileTypes()
  return vim.deepcopy(filetypes)
end

function M.GetLspActionToExec(tool)
  return lsp_actions_autoexec[tool]
end

return M
