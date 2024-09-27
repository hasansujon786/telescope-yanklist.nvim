# telescope-yanklist.nvim

An extension for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) that persists yanks &amp; can search through them. .

# Example mappings

```lua
keymap('n', 'p', '<Plug>(yanklist-auto-put)')
keymap('x', 'p', '<Plug>(yanklist-auto-put)gvy')
keymap('n', 'P', '<Plug>(yanklist-auto-Put)')
keymap('n', '<leader>ii', '<Plug>(yanklist-last-item-put)', { desc = 'Paste from yanklist' })
keymap('x', '<leader>ii', '<Plug>(yanklist-last-item-put)gvy', { desc = 'Paste from yanklist' })
keymap('n', '<leader>iI', '<Plug>(yanklist-last-item-Put)', { desc = 'Paste from yanklist' })

-- Cycle yanklist
keymap('n', '[r', '<Plug>(yanklist-cycle-forward)', { desc = 'Yanklist forward' })
keymap('n', ']r', '<Plug>(yanklist-cycle-backward)', { desc = 'Yanklist backward' })

keymap('n', '<leader>oy', '<cmd>lua require("yanklist").yanklist()<CR>', { desc = 'Show Yank list' })
keymap('x', '<leader>oy', '<Esc><cmd>lua require("yanklist").yanklist_visual()<CR>', { desc = 'Show Yank list' })
```
