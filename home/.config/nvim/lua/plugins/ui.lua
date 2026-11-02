return {
  {
    'folke/which-key.nvim',
    lazy = false,
    config = true,  -- popup that shows what my leader keys do
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  {
    'akinsho/bufferline.nvim',  -- open files as tabs across the top
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous tab' },
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next tab' },
    },
    opts = {
      options = {
        diagnostics = 'nvim_lsp',
        always_show_bufferline = false,
        offsets = { { filetype = 'snacks_layout_box' } },  -- shift tabs right of the explorer
      },
    },
  },
  {
    'nvim-lualine/lualine.nvim',  -- status bar: mode, branch, diagnostics, filetype
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { options = { theme = 'auto', globalstatus = true } },
  },
}
