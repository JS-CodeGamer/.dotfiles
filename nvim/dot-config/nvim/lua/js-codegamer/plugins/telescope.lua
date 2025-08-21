return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope-dap.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-project.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
    },
    config = function()
      local telescope = require 'telescope'
      local themes = require 'telescope.themes'

      telescope.setup {
        pickers = {
          find_files = themes.get_dropdown {
            previewer = false,
          },
          git_files = themes.get_dropdown {
            previewer = false,
            show_untracked = true,
          },
          live_grep = themes.get_ivy {},
          grep_string = themes.get_ivy {},
          buffers = themes.get_dropdown {
            previewer = false,
            sort_lastused = true,
          },
          help_tags = themes.get_cursor {},
          oldfiles = themes.get_dropdown {},
          marks = themes.get_cursor {},
          keymaps = themes.get_ivy {},
          man_pages = themes.get_dropdown {
            previewer = true,
          },
          colorscheme = themes.get_dropdown {
            enable_preview = true,
          },
          diagnostics = themes.get_ivy {},
          lsp_references = themes.get_ivy {},
          lsp_definitions = themes.get_ivy {},
          lsp_implementations = themes.get_ivy {},
          lsp_type_definitions = themes.get_ivy {},
          current_buffer_fuzzy_find = themes.get_ivy {},
          registers = themes.get_cursor {},
          command_history = themes.get_dropdown {},
          search_history = themes.get_dropdown {},
          resume = themes.get_dropdown {},
        },
        extensions = {
          ['ui-select'] = themes.get_dropdown {},
          ['project'] = themes.get_ivy {},
          ['file_browser'] = themes.get_dropdown {
            previewer = false,
            hijack_netrw = true,
          },
        },
      }

      telescope.load_extension 'fzf'
      telescope.load_extension 'ui-select'
      telescope.load_extension 'project'
      telescope.load_extension 'file_browser'
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },
}
