-- save by pressing Escape (only real file buffers, so terminals and pickers are left alone)
vim.keymap.set('n', '<Esc>', function()
  if vim.bo.buftype == '' and vim.bo.modifiable and vim.fn.expand('%') ~= '' then
    vim.cmd('silent! write')
  end
end, { desc = 'Save' })
-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- move between splits (including the Claude terminal) with Ctrl-h/j/k/l
for _, k in ipairs({ 'h', 'j', 'k', 'l' }) do
  vim.keymap.set({ 'n', 't' }, '<C-' .. k .. '>', '<C-\\><C-n><C-w>' .. k, { desc = 'Window ' .. k })
end
-- leave terminal mode
vim.keymap.set('t', '<C-\\><C-\\>', '<C-\\><C-n>', { desc = 'Terminal normal mode' })
