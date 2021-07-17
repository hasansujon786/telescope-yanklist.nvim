let g:yanklist_filename = stdpath('data')."/telescope-yanklist"
let g:yanklist_maxitems = 50
let g:yanklist_delete_maxlines = 1000


augroup YankList
  au!
  au TextYankPost * call yanklist#on_yank(copy(v:event))
  au TextYankPost * silent! lua vim.highlight.on_yank {on_visual=true, higroup = 'Search', timeout = 200}
augroup END

