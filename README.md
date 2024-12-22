# yanklist.nvim

An extension for neovim that persists yanks &amp; can search through them. .

# Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  'hasansujon786/yanklist.nvim',
  event = { 'CursorHold' },
  dependencies = {
    'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua', -- Use fzf-lua as finder
  },
  init = function()
    vim.g.yanklist_finder = 'defalut' -- 'defalut'|'fzf-lua'
  end,
  config = function()
    -- Put mappings
    keymap('n', 'p', '<Plug>(yanklist-auto-put)', { desc = 'Put the text' })
    keymap('n', 'P', '<Plug>(yanklist-auto-Put)', { desc = 'Put the text' })
    keymap('x', 'p', '<Plug>(yanklist-auto-put)gvy', { desc = 'Put the text' })
    keymap('x', 'P', '<Plug>(yanklist-auto-Put)gvy', { desc = 'Put the text' })
    -- Put last item from Yanklist
    keymap('n', '<leader>ii', '<Plug>(yanklist-last-item-put)', { desc = 'Paste from Yanklist' })
    keymap('n', '<leader>iI', '<Plug>(yanklist-last-item-Put)', { desc = 'Paste from Yanklist' })
    keymap('x', '<leader>ii', '<Plug>(yanklist-last-item-put)gvy', { desc = 'Paste from Yanklist' })
    keymap('x', '<leader>iI', '<Plug>(yanklist-last-item-Put)gvy', { desc = 'Paste from Yanklist' })
    -- Cycle through Yanklist items
    keymap('n', '[r', '<Plug>(yanklist-cycle-forward)', { desc = 'Yanklist forward' })
    keymap('n', ']r', '<Plug>(yanklist-cycle-backward)', { desc = 'Yanklist backward' })
    -- Show Yanklist
    keymap('n', '<leader>oy', '<cmd>lua require("yanklist").yanklist()<CR>', { desc = 'Show Yanklist' })
    keymap('x', '<leader>oy', '<Esc><cmd>lua require("yanklist").yanklist_visual()<CR>', { desc = 'Show Yanklist' })
  end,
}
```
