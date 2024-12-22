function! yanklist#read() abort
  if !filereadable(g:yanklist_filename)
    return []
  end
  return msgpackparse(readfile(g:yanklist_filename, 'b'))
endfunction

function! yanklist#write(data) abort
  call writefile(msgpackdump(a:data), g:yanklist_filename, 'b')
endfunction

function! yanklist#add_item(list, item) abort
  for n in range(len(a:list))
    if a:list[n][:1] ==# a:item[:1]
      call remove(a:list, n)
      break
    endif
  endfor
  call insert(a:list, a:item, 0)
  if len(a:list) > g:yanklist_maxitems
    call remove(a:list, g:yanklist_maxitems, -1)
  endif
  return a:list
endfunction

function! yanklist#parse_cb() abort
  let parts = split(&clipboard, ',')
  let cbs = ''
  if index(parts, "unnamed") >= 0
    let cbs = cbs.'*'
  endif
  if index(parts, "unnamedplus") >= 0
    let cbs = cbs.'+'
  endif
  return cbs
endfunction

function! yanklist#on_yank(ev) abort
  if len(a:ev.regcontents) == 1 && len(a:ev.regcontents[0]) <= 1
    return
  end
  " avoid expensive copying on delete unless yanking to a register was
  " explcitly requested
  if a:ev.operator != 'y' && a:ev.regname == '' && len(a:ev.regcontents) > g:yanklist_delete_maxlines
    return
  end
  let state = yanklist#read()
  if a:ev.regname == ''
    let a:ev.regname = yanklist#parse_cb()
  endif
  if g:yanklist_finder == 'fzf-lua'
    call yanklist#add_item(state, [join(a:ev.regcontents, "\n"), a:ev.regtype, a:ev.regname])
  else
    call yanklist#add_item(state, [a:ev.regcontents, a:ev.regtype, a:ev.regname])
  endif
  call yanklist#write(state)
endfunction

" TODO: read about reg 0
function! yanklist#putreg_from_telescope(data,cmd,visual) abort
  let regsave = [getreg('0'), getregtype('0')]
  call setreg('0', a:data[0], a:data[1])
  execute 'normal! '.(a:visual ? 'gv' : '').'"0'.a:cmd
  call setreg('0', regsave[0], regsave[1])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO: this should be a nvim builtin
function! yanklist#putreg(data,cmd) abort
  let regsave = [getreg('0'), getregtype('0')]
  call setreg('0', a:data[0], a:data[1])
  execute 'normal! '.(s:visual ? 'gv' : '').s:count.'"0'.a:cmd
  let g:foo = 'normal! '.(s:visual ? 'gv' : '').s:count.'"0'.a:cmd
  call setreg('0', regsave[0], regsave[1])
  let s:last = a:data[0]
endfunction

" work-around nvim:s lack of register types in clipboard
" only use this when clipboard=unnamed[plus]
" otherwise you are expected to use startput
function! yanklist#fix_clip(list, pasted) abort
  if !has("nvim")
    return v:false
  end
  if stridx('*+', a:pasted[2]) < 0 || yanklist#parse_cb() ==# '' || len(a:list) == 0
    return v:false
  endif
  let last = a:list[0]
  if stridx(last[2], a:pasted[2]) < 0
    return v:false
  endif
  if last[1] ==# 'v' && len(last[0]) >= 2 && last[0][-1] == ''
    " this would been had missinterpreted as a line, but is a charwise
    return a:pasted[1] == 'V' && a:pasted[0] ==# last[0][:-2]
  endif
  return a:pasted[1] ==# 'V' && a:pasted[0] ==# last[0]
endfunction

let s:changedtick = -1

" call yanklist#insertLastItem("p",0)
" TODO: put autocommand plz
function! yanklist#startput(cmd,defer) abort
  if mode(1) ==# "no"
    return a:cmd " don't override diffput
  end
  let s:pastelist = yanklist#read()
  let s:pos = 0
  let s:cmd = a:cmd
  let s:visual = index(["v","V","\026"], mode()) >= 0
  let s:count = string(v:count1)
  if a:defer
    let first = [getreg(v:register,0,1), getregtype(v:register), v:register]
    if !yanklist#fix_clip(s:pastelist, first)
      call yanklist#add_item(s:pastelist, first)
    endif
  end
  return ":\<c-u>call yanklist#do_putlist()\015"
endfunction

function! yanklist#cycle(dir) abort
  if s:changedtick != b:changedtick
    return
  end
  if a:dir > 0 " forward
    if s:pos+a:dir >= len(s:pastelist)
      echoerr "yanklist: no more items!"
      return
    endif
  elseif a:dir < 0 " backward
    if s:pos+a:dir < 0
      echoerr "yanklist: no previous items!"
      return
    endif
  end
  let s:pos += a:dir
  silent undo
  call yanklist#do_putlist()
endfunction

function! yanklist#do_putlist() abort
  call yanklist#putreg(s:pastelist[s:pos],s:cmd)
  let s:changedtick = b:changedtick
endfunction

function! yanklist#force_motion(motion) abort
  if s:changedtick != b:changedtick
    return
  end
  silent undo
  call yanklist#putreg([s:last, a:motion], s:cmd)
  let s:changedtick = b:changedtick
endfunction

" FIXME: integrate with the rest
function! yanklist#drop(data,cmd) abort
  let s:pastelist = [a:data]
  let s:pos = 0
  let s:visual = ''
  let s:count = 1
  let s:cmd = a:cmd
  " why not putreg??
  call yanklist#do_putlist()
endfunction

