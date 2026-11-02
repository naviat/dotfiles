return {
  {
    'stevearc/oil.nvim',
    opts = {
      default_file_explorer = false,  -- the sidebar explorer (snacks) owns directories
      view_options = { show_hidden = true },
    },
    keys = { { '-', '<cmd>Oil<cr>', desc = 'Edit directory as a buffer' } },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true, sources = { explorer = { hidden = true } } },
      explorer = { enabled = true, replace_netrw = true },  -- `nvim .` opens the sidebar
      notifier = { enabled = true },
      input = { enabled = true },
      terminal = { enabled = true },
      bufdelete = { enabled = true },
    },
    keys = {
      { '<leader>e', function() Snacks.explorer() end, desc = 'Sidebar explorer' },
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>s', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>p', function() Snacks.picker.commands() end, desc = 'Command palette' },
      { '<leader>o', function() Snacks.picker.lsp_symbols() end, desc = 'Symbols in file' },
      { '<leader>d', function() Snacks.picker.diagnostics() end, desc = 'Problems' },
      { '<leader>x', function() Snacks.bufdelete() end, desc = 'Close buffer' },
      { '<leader>t', function() Snacks.terminal.toggle(nil, { win = { position = 'bottom', height = 0.3 } }) end, desc = 'Terminal panel' },
      { '<C-/>', function() Snacks.terminal.toggle(nil, { win = { position = 'bottom', height = 0.3 } }) end, mode = { 'n', 't' }, desc = 'Terminal panel' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
  },
}
