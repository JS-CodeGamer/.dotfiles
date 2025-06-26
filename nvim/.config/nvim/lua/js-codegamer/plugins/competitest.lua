return {
  'xeluxee/competitest.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  cmd = { 'CompetiTest', 'CptInit', 'CptTest', 'CptProb', 'CptCont' },
  opts = {
    runner_ui = {
      -- interface = 'popup',
      interface = 'split',
      show_nu = false,
      selector_show_nu = true,
      selector_show_rnu = true,
    },
    popup_ui = {
      layout = {
        { 1, {
          { 1, 'so' },
          { 1, { { 1, 'tc' }, { 1, 'se' } } },
        } },
        { 1, {
          { 1, 'eo' },
          { 1, 'si' },
        } },
      },
    },
    split_ui = {
      vertical_layout = {
        { 1, 'tc' },
        { 2, { { 1, 'so' }, { 1, 'eo' } } },
        { 2, { { 1, 'si' }, { 1, 'se' } } },
      },
    },
    compile_directory = 'build',
    compile_command = {
      c = { exec = 'clang', args = { '-Wall', '../$(FNAME)', '-o', '$(FNOEXT)' } },
      cpp = { exec = 'clang++', args = { '-Wall', '../$(FNAME)', '-o', '$(FNOEXT)' } },
      rust = {
        exec = 'bash',
        args = { '-c', 'rustc \'../$(FNAME)\' -o \'$(FNOEXT)\' --crate-name $()( echo $(FNOEXT) | tr " " "_")' },
      },
    },
    running_directory = 'build',
    testcases_directory = '.tc',
    testcases_use_single_file = true,
    template_file = '$(HOME)/dev/cp/.templates/template.$(FEXT)',
    evaluate_template_modifiers = true,
    received_problems_path = '$(HOME)/dev/cp/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)',
    received_contests_directory = '$(HOME)/dev/cp/$(JUDGE)/$(CONTEST)',
    received_contests_problems_path = '$(PROBLEM).$(FEXT)',
  },
}
