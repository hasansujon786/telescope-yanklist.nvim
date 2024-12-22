let g:yanklist_finder = get(g:, 'yanklist_finder', 'default')
let g:yanklist_filename = stdpath('data').'/yanklist-'.g:yanklist_finder
let g:yanklist_maxitems = 50
let g:yanklist_delete_maxlines = 1000

augroup YankList
  au!
  au TextYankPost * call yanklist#on_yank(copy(v:event))
augroup END

noremap <silent> <expr> <Plug>(yanklist-auto-put) yanklist#startput("p",1)
noremap <silent> <expr> <Plug>(yanklist-auto-Put) yanklist#startput("P",1)
noremap <silent> <expr> <Plug>(yanklist-last-item-put) yanklist#startput("p",0)
noremap <silent> <expr> <Plug>(yanklist-last-item-Put) yanklist#startput("P",0)
noremap <silent> <Plug>(yanklist-cycle-forward) :<c-u>call yanklist#cycle(1)<cr>
noremap <silent> <Plug>(yanklist-cycle-backward) :<c-u>call yanklist#cycle(-1)<cr>
