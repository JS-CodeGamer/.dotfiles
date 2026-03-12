-- tools.lua: Centralized management for LSP servers, formatters, and linters
local cjson_imported, cjson = pcall(require, 'cjson')

local config_path = vim.fn.stdpath 'config' .. '/tools.jsonc'

-- Cache for parsed data and computed mappings
local cache = {
  data = nil,
  filetypes = nil,
  filetype_to_server = nil,
  filetype_to_formatter = nil,
  filetype_to_linter = nil,
  tool_to_mason = nil,
  mason_exclude = nil,
  lsp_actions_autoexec = nil,
  lsp_settings_ = nil,
  last_modified = nil,
}

-- Enhanced JSON parsing with better error handling
local function parse_tools_config()
  local stat = vim.loop.fs_stat(config_path)
  if not stat then
    vim.notify('Tools config file not found: ' .. config_path, vim.log.levels.WARN)
    return {}
  end

  -- Check cache validity
  if cache.data and cache.last_modified == stat.mtime.sec then
    return cache.data
  end

  local data = {}
  if cjson_imported then
    local file, err = io.open(config_path, 'r')
    if not file then
      vim.notify('Failed to read tools config: ' .. err, vim.log.levels.ERROR)
      return {}
    end

    local content = {}
    for line in file:lines() do
      -- Remove // comments and trim whitespace
      local comment_loc = line:find '//'
      if comment_loc then
        line = line:sub(0, comment_loc - 1)
      end
      line = vim.trim(line)
      if line ~= '' then
        table.insert(content, line)
      end
    end
    file:close()

    local json_content = table.concat(content, '\n')
    local ok, parsed_data = pcall(cjson.decode, json_content)
    if not ok then
      vim.notify('Failed to decode JSON from tools config: ' .. tostring(parsed_data), vim.log.levels.ERROR)
      return {}
    end

    data = parsed_data
    
    -- Update cache
    cache.data = data
    cache.last_modified = stat.mtime.sec
    -- Invalidate computed mappings
    cache.filetypes = nil
    cache.filetype_to_server = nil
    cache.filetype_to_formatter = nil
    cache.filetype_to_linter = nil
  else
    vim.notify('cjson not available, using empty tools config', vim.log.levels.WARN)
  end

  return data
end

local data = parse_tools_config()

-- Lazy computation of mappings with caching
local function get_filetypes()
  if cache.filetypes then return cache.filetypes end
  
  local filetypes = {}
  for ft, _ in pairs(data.tools or {}) do
    if ft ~= '*' then
      table.insert(filetypes, ft)
    end
  end
  
  cache.filetypes = filetypes
  return filetypes
end

local function get_filetype_to_server()
  if cache.filetype_to_server then return cache.filetype_to_server end
  
  local filetype_to_server = {}
  for ft, ft_data in pairs(data.tools or {}) do
    if ft_data['lsp-server'] then
      filetype_to_server[ft] = ft_data['lsp-server']
    end
  end
  
  cache.filetype_to_server = filetype_to_server
  return filetype_to_server
end

local function get_filetype_to_formatter()
  if cache.filetype_to_formatter then return cache.filetype_to_formatter end
  
  local filetype_to_formatter = {}
  for ft, ft_data in pairs(data.tools or {}) do
    if ft_data['formatter'] then
      filetype_to_formatter[ft] = ft_data['formatter']
    end
  end
  
  cache.filetype_to_formatter = filetype_to_formatter
  return filetype_to_formatter
end

local function get_filetype_to_linter()
  if cache.filetype_to_linter then return cache.filetype_to_linter end
  
  local filetype_to_linter = {}
  for ft, ft_data in pairs(data.tools or {}) do
    if ft_data['linter'] then
      filetype_to_linter[ft] = ft_data['linter']
    end
  end
  
  cache.filetype_to_linter = filetype_to_linter
  return filetype_to_linter
end

local function get_tool_to_mason()
  if cache.tool_to_mason then return cache.tool_to_mason end
  
  cache.tool_to_mason = data['tool-to-mason'] or {}
  return cache.tool_to_mason
end

local function get_mason_exclude()
  if cache.mason_exclude then return cache.mason_exclude end
  
  cache.mason_exclude = data['mason-exclude'] or {}
  return cache.mason_exclude
end

local function get_lsp_actions_autoexec()
  if cache.lsp_actions_autoexec then return cache.lsp_actions_autoexec end
  
  cache.lsp_actions_autoexec = data['lsp-action-autoexec'] or {}
  return cache.lsp_actions_autoexec
end

local function get_lsp_settings()
  if cache.lsp_settings_ then return cache.lsp_settings_ end
  
  cache.lsp_settings_ = data['lsp-settings'] or {}
  return cache.lsp_settings_
end

local function lsp_settings()
  local base_settings = get_lsp_settings()
  local dynamic_settings = {}
  
  -- Add JSON schema store if available
  local ok_schemastore, schemastore = pcall(require, 'schemastore')
  if ok_schemastore then
    dynamic_settings.jsonls = {
      settings = {
        json = {
          schemas = schemastore.json.schemas(),
          validate = { enable = true },
        },
      },
    }
  end
  
  -- Add TypeScript settings if ts_utils is available
  local ok_tsutils, ts_utils = pcall(require, 'nvim-lsp-ts-utils')
  if ok_tsutils then
    dynamic_settings.tsserver = ts_utils.get_settings()
  end
  
  return vim.tbl_deep_extend('force', base_settings, dynamic_settings)
end

-- Function to reload configuration and invalidate cache
local function reload_config()
  cache.data = nil
  cache.last_modified = nil
  cache.filetypes = nil
  cache.filetype_to_server = nil
  cache.filetype_to_formatter = nil
  cache.filetype_to_linter = nil
  cache.tool_to_mason = nil
  cache.mason_exclude = nil
  cache.lsp_actions_autoexec = nil
  cache.lsp_settings_ = nil
  
  data = parse_tools_config()
  vim.notify('Tools configuration reloaded', vim.log.levels.INFO)
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
  local servers = get_filetype_to_server()
  if filetype == nil then
    return vim.deepcopy(servers)
  else
    return servers[filetype]
  end
end

-- Get formatters for each filetype
function M.GetFormatters(filetype)
  local formatters = get_filetype_to_formatter()
  if filetype == nil then
    return vim.deepcopy(formatters)
  else
    return formatters[filetype]
  end
end

-- Get linters for each filetype
function M.GetLinters(filetype)
  local linters = get_filetype_to_linter()
  if filetype == nil then
    return vim.deepcopy(linters)
  else
    return linters[filetype]
  end
end

-- Get all Mason tools required for a specific filetype
function M.GetMasonToolsForFT(filetype)
  local tools = {}
  local tool_to_mason = get_tool_to_mason()
  local mason_exclude = get_mason_exclude()

  local function register_to_tools(itools)
    itools = itools or {}
    for _, tool in ipairs(itools) do
      if not mason_exclude[tool] then
        table.insert(tools, tool_to_mason[tool] or tool)
      end
    end
  end

  local servers = get_filetype_to_server()
  local formatters = get_filetype_to_formatter()
  local linters = get_filetype_to_linter()

  register_to_tools(servers[filetype])
  register_to_tools(formatters[filetype])
  register_to_tools(linters[filetype])

  return tools
end

function M.getTSFileTypes()
  return vim.deepcopy(get_filetypes())
end

function M.GetLspActionToExec(tool)
  local actions = get_lsp_actions_autoexec()
  return actions[tool]
end

-- Additional utility functions
function M.GetSupportedFiletypes()
  return vim.deepcopy(get_filetypes())
end

function M.HasLSPServer(filetype)
  local servers = get_filetype_to_server()
  return servers[filetype] ~= nil
end

function M.HasFormatter(filetype)
  local formatters = get_filetype_to_formatter()
  return formatters[filetype] ~= nil
end

function M.HasLinter(filetype)
  local linters = get_filetype_to_linter()
  return linters[filetype] ~= nil
end

function M.ReloadConfig()
  reload_config()
end

function M.GetConfigPath()
  return config_path
end

function M.IsConfigAvailable()
  return vim.loop.fs_stat(config_path) ~= nil
end

return M
