return {
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {},
    keys = {
      { '<leader>ac', '<cmd>ClaudeCode<cr>',            desc = 'Claude toggle' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>',       desc = 'Claude focus' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>',   desc = 'Claude resume' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Claude continue' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>',       desc = 'Claude add buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Claude send selection' },
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>',  desc = 'Claude accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>',    desc = 'Claude deny diff' },
    },
  },
}
