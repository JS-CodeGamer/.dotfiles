return {
  'xeluxee/competitest.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  cmd = 'CompetiTest',
  keys = {
    {
      '<leader>cprt',
      '<cmd>CompetiTest receive testcases<cr>',
      desc = 'CompetiTest: receive Testcases',
    },
    {
      '<leader>cprp',
      '<cmd>CompetiTest receive problem<cr>',
      desc = 'CompetiTest: receive Problem',
    },
    {
      '<leader>cpt',
      '<cmd>CompetiTest run<cr>',
      desc = 'CompetiTest: Run testcases',
    },
  },
  opts = {
    received_problems_path = '$(HOME)/dev/cp/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)',
    received_contests_directory = '$(HOME)/dev/cp/$(JUDGE)/$(CONTEST)',
    received_contests_problems_path = '$(PROBLEM)/main.$(FEXT)',
    template_file = '$(HOME)/dev/cp/.templates/template.$(FEXT)',
    evaluate_template_modifiers = true,
  },
  config = function(_, opts)
    require('competitest').setup(opts)
  end,
}
