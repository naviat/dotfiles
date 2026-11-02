return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = { 'rafamadriz/friendly-snippets' },  -- snippets for terraform, go, python, shell
    opts = {
      -- Tab accepts the suggestion or jumps to the next snippet field; C-n/C-p pick
      keymap = { preset = 'super-tab' },
      fuzzy = { implementation = 'lua' },  -- no prebuilt binary download
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      completion = {
        trigger = { show_on_keyword = true },  -- suggest while typing, no key needed
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },       -- grey preview of the top suggestion
        menu = { border = 'rounded' },
      },
      signature = { enabled = true },  -- argument hints while typing a call
    },
  },
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = {
        terraform = { 'terraform_fmt' },
        ['terraform-vars'] = { 'terraform_fmt' },
        go = { 'goimports', 'gofumpt' },
        python = { 'ruff_fix', 'ruff_format' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        nix = { 'nixfmt' },
        lua = { 'stylua' },
      },
      format_on_save = { timeout_ms = 3000, lsp_format = 'fallback' },
    },
  },
}
