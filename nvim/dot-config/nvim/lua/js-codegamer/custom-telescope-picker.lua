local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  return {}
end

local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf = require('telescope.config').values
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local pickers = require 'telescope.pickers'
local sorters = require 'telescope.sorters'

local M = {}
local uv = vim.uv or vim.loop

local defaults = {
  command = 'rg',
  command_args = {
    '--vimgrep',
    '--no-heading',
    '--with-filename',
    '--line-number',
    '--column',
    '--smart-case',
  },
  debounce_ms = 80,
  batch_size = 500,
  prompt_title = 'Filter Grep',
  min_query_length = 1,
  cwd = nil,
  notify_errors = true,
}

local config = vim.deepcopy(defaults)

local function trim(value)
  return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

---Parse the Telescope prompt into the rg query and ordered filter stages.
---
---Everything before the first `||` is the ripgrep query. Later segments are
---case-insensitive substring filters. A leading `!` makes the stage negative.
---@param prompt string
---@return string query
---@return table[] filters
function M.parse_prompt(prompt)
  local parts = vim.split(prompt or '', '||', { plain = true })
  local query = trim(parts[1] or '')
  local filters = {}

  for index = 2, #parts do
    local raw = trim(parts[index])
    if raw ~= '' then
      local exclude = raw:sub(1, 1) == '!'
      local text = exclude and trim(raw:sub(2)) or raw

      if text ~= '' then
        filters[#filters + 1] = {
          text = text,
          lower = text:lower(),
          exclude = exclude,
        }
      end
    end
  end

  return query, filters
end

---Apply ordered include/exclude filters to cached rg result objects.
---
---Each result stores a lowercase copy of the full vimgrep display line so
---filtering avoids reparsing Telescope entries on every prompt change.
---@param results table[]
---@param filters table[]
---@return table[]
function M.apply_filters(results, filters)
  if #filters == 0 then
    return results
  end

  local filtered = {}
  local filtered_count = 0

  for result_index = 1, #results do
    local result = results[result_index]
    local line = result.lower
    local keep = true

    for filter_index = 1, #filters do
      local filter = filters[filter_index]
      local matched = line:find(filter.lower, 1, true) ~= nil

      if filter.exclude then
        if matched then
          keep = false
          break
        end
      elseif not matched then
        keep = false
        break
      end
    end

    if keep then
      filtered_count = filtered_count + 1
      filtered[filtered_count] = result
    end
  end

  return filtered
end

local function make_passthrough_sorter()
  return sorters.Sorter:new {
    scoring_function = function()
      return 1
    end,
    highlighter = function()
      return {}
    end,
  }
end

local function selection_key(entry)
  if not entry then
    return nil
  end

  return table.concat({
    entry.filename or '',
    tostring(entry.lnum or ''),
    tostring(entry.col or ''),
    entry.text or entry.value or '',
  }, '\0')
end

local function current_prompt(prompt_bufnr)
  local ok, line = pcall(action_state.get_current_line)
  if ok and line then
    return line
  end

  local lines = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, 1, false)
  return lines[1] or ''
end

local function new_finder(state, rows)
  return finders.new_table {
    results = rows,
    entry_maker = function(item)
      if item.entry then
        return item.entry
      end

      local entry = state.vimgrep_entry_maker(item.raw)
      item.entry = entry
      return entry
    end,
  }
end

---Refresh the Telescope picker from the current filtered result set.
---
---`reset_prompt = false` keeps the prompt text intact. The current row is
---restored when Telescope can still select it after filtering.
---@param state table
function M.refresh_picker(state)
  if state.closed or not state.picker then
    return
  end

  local picker = state.picker
  local previous_row = picker:get_selection_row()
  local previous_key = selection_key(picker:get_selection())

  picker:refresh(new_finder(state, state.filtered_results), {
    reset_prompt = false,
  })

  if previous_key then
    vim.schedule(function()
      if state.closed or not state.picker then
        return
      end

      local target_row = previous_row
      for row = 1, #state.filtered_results do
        local entry = state.filtered_results[row].entry
        if entry and selection_key(entry) == previous_key then
          target_row = row
          break
        end
      end

      if target_row and target_row > 0 and target_row <= #state.filtered_results then
        pcall(state.picker.set_selection, state.picker, target_row)
      end
    end)
  end
end

local function schedule_refresh(state, force)
  if state.closed then
    return
  end

  if force then
    if state.refresh_timer then
      state.refresh_timer:stop()
    end
    M.refresh_picker(state)
    return
  end

  if state.refresh_pending then
    return
  end

  state.refresh_pending = true
  state.refresh_timer:start(state.config.debounce_ms, 0, function()
    vim.schedule(function()
      if state.closed then
        return
      end

      state.refresh_pending = false
      M.refresh_picker(state)
    end)
  end)
end

local function cancel_job(state)
  if state.job and not state.job:is_closing() then
    pcall(state.job.kill, state.job, 15)
  end

  state.job = nil
end

local function close_timer(timer)
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

local function cleanup_state(state)
  if state.closed then
    return
  end

  state.closed = true
  cancel_job(state)
  close_timer(state.refresh_timer)
  close_timer(state.prompt_timer)
end

local function add_rg_output(state, data, generation)
  if state.closed or generation ~= state.generation or not data or data == '' then
    return
  end

  local text = state.stdout_remainder .. data
  local lines = vim.split(text, '\n', { plain = true })

  state.stdout_remainder = table.remove(lines) or ''

  local added = 0
  for index = 1, #lines do
    local raw = lines[index]
    if raw ~= '' then
      state.results[#state.results + 1] = {
        raw = raw,
        lower = raw:lower(),
      }
      added = added + 1
    end
  end

  if added > 0 then
    state.filtered_results = M.apply_filters(state.results, state.filters)

    if added >= state.config.batch_size then
      schedule_refresh(state, true)
    else
      schedule_refresh(state, false)
    end
  end
end

---Launch an asynchronous ripgrep job for the query and cache raw vimgrep rows.
---
---Changing the rg portion of the prompt increments `generation`, so stale
---stdout/exit callbacks from killed jobs are ignored without coordination.
---@param state table
---@param query string
function M.run_rg(state, query)
  cancel_job(state)

  state.generation = state.generation + 1
  state.current_query = query
  state.results = {}
  state.filtered_results = {}
  state.stdout_remainder = ''
  state.stderr = {}

  local generation = state.generation

  if #query < state.config.min_query_length then
    schedule_refresh(state, true)
    return
  end

  local args = vim.list_extend(vim.deepcopy(state.config.command_args), { query })
  state.job = vim.system(vim.list_extend({ state.config.command }, args), {
    cwd = state.config.cwd,
    text = true,
    stdout = function(_, data)
      vim.schedule(function()
        add_rg_output(state, data, generation)
      end)
    end,
    stderr = function(_, data)
      if data and data ~= '' then
        vim.schedule(function()
          if generation == state.generation then
            state.stderr[#state.stderr + 1] = data
          end
        end)
      end
    end,
  }, function(result)
    vim.schedule(function()
      if state.closed or generation ~= state.generation then
        return
      end

      if state.stdout_remainder ~= '' then
        local raw = state.stdout_remainder
        state.results[#state.results + 1] = {
          raw = raw,
          lower = raw:lower(),
        }
        state.stdout_remainder = ''
      end

      state.filtered_results = M.apply_filters(state.results, state.filters)
      schedule_refresh(state, true)

      if result.code > 1 and state.config.notify_errors then
        local message = trim(table.concat(state.stderr))
        if message ~= '' then
          vim.notify(message, vim.log.levels.ERROR, { title = 'telescope-filtergrep' })
        end
      end
    end)
  end)
end

---Handle prompt edits from Telescope's prompt buffer.
---
---Only the rg query invalidates the cache. Filter-only changes recompute the
---visible rows from cached results and refresh the picker.
---@param state table
---@param prompt string
function M.on_prompt_changed(state, prompt)
  local query, filters = M.parse_prompt(prompt)
  state.filters = filters

  if query ~= state.current_query then
    M.run_rg(state, query)
    return
  end

  state.filtered_results = M.apply_filters(state.results, filters)
  schedule_refresh(state, true)
end

local function attach_prompt_listener(state, prompt_bufnr)
  vim.api.nvim_buf_attach(prompt_bufnr, false, {
    on_detach = function()
      cleanup_state(state)
    end,
    on_lines = function()
      if state.prompt_timer_active then
        return
      end

      state.prompt_timer_active = true
      state.prompt_timer:start(state.config.debounce_ms, 0, function()
        vim.schedule(function()
          if state.closed then
            return
          end

          state.prompt_timer_active = false
          M.on_prompt_changed(state, current_prompt(prompt_bufnr))
        end)
      end)
    end,
  })
end

function M.filtergrep(opts)
  opts = opts or {}

  local picker_opts = vim.tbl_deep_extend('force', {}, config, opts)
  local state = {
    config = picker_opts,
    current_query = nil,
    filters = {},
    results = {},
    filtered_results = {},
    generation = 0,
    stdout_remainder = '',
    stderr = {},
    refresh_pending = false,
    prompt_timer_active = false,
    closed = false,
    refresh_timer = uv.new_timer(),
    prompt_timer = uv.new_timer(),
    vimgrep_entry_maker = make_entry.gen_from_vimgrep(picker_opts),
  }

  local picker = pickers.new(picker_opts, {
    prompt_title = picker_opts.prompt_title,
    finder = new_finder(state, state.filtered_results),
    previewer = conf.grep_previewer(picker_opts),
    sorter = make_passthrough_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      state.picker = action_state.get_current_picker(prompt_bufnr)

      attach_prompt_listener(state, prompt_bufnr)

      vim.schedule(function()
        if not state.closed then
          M.on_prompt_changed(state, current_prompt(prompt_bufnr))
        end
      end)

      map({ 'i', 'n' }, '<C-r>', function()
        local query, filters = M.parse_prompt(current_prompt(prompt_bufnr))
        state.filters = filters
        state.current_query = nil
        M.run_rg(state, query)
      end)

      map({ 'i', 'n' }, '<C-c>', function()
        cleanup_state(state)
        actions.close(prompt_bufnr)
      end)

      return true
    end,
  })

  state.picker = picker
  picker:find()
end

M.live_grep = M.filtergrep

function M.setup(opts)
  config = vim.tbl_deep_extend('force', {}, defaults, opts or {})
end

package.preload['telescope._extensions.filtergrep'] = function()
  return telescope.register_extension {
    setup = function(ext_config)
      M.setup(ext_config)
    end,
    exports = {
      filtergrep = M.filtergrep,
    },
  }
end

vim.api.nvim_create_user_command('FilterGrep', function(command)
  M.filtergrep {
    default_text = command.args ~= '' and command.args or nil,
  }
end, {
  nargs = '*',
  desc = 'Telescope grep with cached iterative filters',
})

return M
