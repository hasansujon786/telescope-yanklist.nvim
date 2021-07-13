let g:yanklist_filename = stdpath('data')."/telescope-yanklist"
let g:yanklist_maxitems = 50
let g:yanklist_delete_maxlines = 1000


augroup YankList
  au! TextYankPost * call yanklist#on_yank(copy(v:event))
augroup END

