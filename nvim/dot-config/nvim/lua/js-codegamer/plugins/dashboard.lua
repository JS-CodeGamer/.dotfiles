local theme = 'hyper'
-- local theme = 'doom'

local header = {
  [[╭──────────────────────────────────────────────────────────────╮]],
  [[│                                                              │]],
  [[│                                                              │]],
  [[│     ━━┏┓┏━━━┓━━━━━┏━━━┓━━━━━━┏┓━━━━┏━━━┓━━━━━━━━━━━━━━━━     │]],
  [[│     ━━┃┃┃┏━┓┃━━━━━┃┏━┓┃━━━━━━┃┃━━━━┃┏━┓┃━━━━━━━━━━━━━━━━     │]],
  [[│     ━━┃┃┃┗━━┓━━━━━┃┃━┗┛┏━━┓┏━┛┃┏━━┓┃┃━┗┛┏━━┓━┏┓┏┓┏━━┓┏━┓     │]],
  [[│     ┏┓┃┃┗━━┓┃━━━━━┃┃━┏┓┃┏┓┃┃┏┓┃┃┏┓┃┃┃┏━┓┗━┓┃━┃┗┛┃┃┏┓┃┃┏┛     │]],
  [[│     ┃┗┛┃┃┗━┛┃━━━━━┃┗━┛┃┃┗┛┃┃┗┛┃┃┃━┫┃┗┻━┃┃┗┛┗┓┃┃┃┃┃┃━┫┃┃━     │]],
  [[│     ┗━━┛┗━━━┛━━━━━┗━━━┛┗━━┛┗━━┛┗━━┛┗━━━┛┗━━━┛┗┻┻┛┗━━┛┗┛━     │]],
  [[│     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     │]],
  [[│     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     │]],
  [[│                                                              │]],
  [[│                                                              │]],
  [[╰──────────────────────────────────────────────────────────────╯]],
}

local hyper_config = {
  shortcut = {
    {
      desc = ' Update',
      group = '@property',
      action = 'Lazy update',
      key = 'u',
    },
    {
      desc = ' Files',
      group = 'Label',
      action = 'Telescope find_files',
      key = 'f',
    },
    {
      desc = ' Projects',
      group = 'Number',
      action = 'Telescope project',
      key = 'p',
    },
    {
      desc = ' Recent',
      group = 'DiagnosticHint',
      action = 'Telescope oldfiles',
      key = 'r',
    },
    {
      desc = ' Settings',
      group = 'String',
      action = function()
        require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
      end,
      key = 's',
    },
    {
      desc = ' Quit',
      group = 'Error',
      action = 'quit',
      key = 'q',
    },
  },
  packages = { enable = true },
  project = { enable = true, limit = 3, icon = ' ', label = 'Recent Projects', action = 'Telescope find_files cwd=' },
  mru = { limit = 20, icon = ' ', label = 'Recent Files', action = 'e' },
  footer = {},
}

local doom_config = {
  center = {
    {
      icon = ' ',
      icon_hl = 'Title',
      desc = 'Find File           ',
      desc_hl = 'String',
      key = 'b',
      keymap = 'SPC s f',
      key_hl = 'Number',
      key_format = ' %s', -- remove default surrounding `[]`
      action = 'lua print(2)',
    },
    {
      icon = ' ',
      desc = 'Find Dotfiles',
      key = 'f',
      keymap = 'SPC f d',
      key_format = ' %s', -- remove default surrounding `[]`
      action = 'lua print(3)',
    },
  },
  footer = {}, --your footer
}

local config = {
  header = header,
  week_header = { enable = true, append = { 'JS-CodeGamer' } },
}
if theme == 'hyper' then
  config = vim.tbl_deep_extend('force', config, hyper_config)
else
  config = vim.tbl_deep_extend('force', config, doom_config)
end

return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  opts = {
    theme = theme,
    change_to_vcs_root = true,
    config = config,
  },
}
