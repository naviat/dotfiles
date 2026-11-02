-- Language servers come from Nix (common.nix), not Mason, so they stay reproducible.
return {
  {
    'neovim/nvim-lspconfig',  -- ships the default lsp/*.lua server definitions
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      -- tell every server that blink.cmp can render its completions
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

      vim.lsp.config('lua_ls', {
        settings = { Lua = { diagnostics = { globals = { 'vim', 'Snacks' } } } },
      })

      vim.lsp.enable({
        'terraformls',   -- terraform: completion, schema, validation
        'tflint',        -- terraform: lint rules
        'gopls',
        'basedpyright',
        'ruff',
        'bashls',        -- also runs shellcheck
        'nixd',
        'lua_ls',
      })

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = 'rounded' },
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local parsers = {
        'terraform', 'hcl', 'go', 'gomod', 'python', 'bash', 'nix', 'lua',
        'yaml', 'json', 'toml', 'markdown', 'markdown_inline', 'dockerfile',
      }
      require('nvim-treesitter').install(parsers)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
