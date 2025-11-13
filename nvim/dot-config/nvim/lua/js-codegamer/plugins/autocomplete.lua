return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim',
      { 'folke/lazydev.nvim', opts = {} },
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'

      luasnip.config.setup {
        keep_roots = true,
        link_roots = true,
        exit_roots = true,
        link_children = true,
        updateevents = 'TextChanged,TextChangedI',
        enable_autosnippets = true,
      }
      local snip_expander = function(args)
        luasnip.lsp_expand(args.body)
      end

      local lspkind_format = lspkind.cmp_format {
        mode = 'symbol_text',
        menu = {
          buffer = '[Buffer]',
          nvim_lsp = '[LSP]',
          luasnip = '[Snippet]',
          path = '[Path]',
          cmdline = '[Cmd]',
        },
      }

      cmp.setup {
        enabled = function()
          return not require('cmp.config.context').in_treesitter_capture 'comment'
        end,
        snippet = { expand = snip_expander },
        window = {
          completion = cmp.config.window.bordered {
            winhighlight = 'Normal:CmpNormal',
            border = 'rounded',
          },
        },
        completion = { keyword_length = 1 },
        formatting = { format = lspkind_format },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = "lazydev",  group_index = 0 },
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip',  priority = 750 },
          { name = 'path',     priority = 500 },
          { name = 'buffer',   priority = 250, keyword_length = 3, max_item_count = 10 },
        },
        experimental = { ghost_text = true },
      }

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = 'cmdline' }, { name = 'path' } },
      })

      local autopairs_cmp = require 'nvim-autopairs.completion.cmp'
      cmp.event:on('confirm_done', autopairs_cmp.on_confirm_done())
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    event = 'InsertEnter',
    dependencies = { 'rafamadriz/friendly-snippets' },
    build = function()
      if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
        return
      end
      return 'make install_jsregexp'
    end,
    config = function()
      require('luasnip').filetype_extend('javascriptreact', { 'html', 'javascript' })
      require('luasnip').filetype_extend('typescriptreact', { 'html', 'typescript' })
      require('luasnip').filetype_extend('markdown', { 'tex' })
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local npairs = require 'nvim-autopairs'
      npairs.setup {
        check_ts = true,
        ts_config = {
          lua = { 'string' },
          javascript = { 'template_string' },
          java = false,
        },
        disable_filetype = { 'TelescopePrompt' },
        fast_wrap = {
          map = '<M-e>',
          chars = { '{', '[', '(', '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
          end_key = '$',
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          check_comma = true,
          highlight = 'Search',
          highlight_grey = 'Comment',
        },
      }

      local Rule = require 'nvim-autopairs.rule'
      npairs.add_rules {
        Rule(' ', ' '):with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ '()', '[]', '{}' }, pair)
        end),
      }
    end,
  },
}
