let s:prev_errmsg = ''
let s:prev_warningmsg = ''
let s:command_line_mode = ''

" FUNCTION StartCommandLine
" Sound for command line start. I assume this affects scripts, too.
function! speech#command_line#StartCommandLine(key)
  let s:command_line_mode = ':'

  call speech#sound#Play('command.wav')

  " Attach space to error and warning string to catch new values.
  if s:prev_errmsg !=# v:errmsg
    let v:errmsg = v:errmsg . '|' 
    let s:prev_errmsg = v:errmsg
  endif
  if s:prev_warningmsg !=# v:warningmsg
    let s:prev_warningmsg = v:warningmsg
    let v:warningmsg = v:warningmsg . '|' 
  endif

  return a:key
endfunction

" FUNCTION EndCommandLine
" Check several states to produce a helpful feedback.
function! speech#command_line#EndCommandLine()
  if s:prev_errmsg !=# v:errmsg
    call speech#Speak(v:errmsg)
  elseif s:prev_warningmsg !=# v:warningmsg
    call speech#Speak(v:warningmsg)
  else
    if s:command_line_mode ==# '/'
      call speech#command_line#EndSearch()
    else
      call speech#sound#Error()
    endif
  endif
  let s:command_line_mode = ''
  return ''
endfunction


" FUNCTION EndSearch
" Called by EndCommandLine if it was a search command.
function! speech#command_line#EndSearch()
  "call speech#PreserveCursor('call speech#Movement("yaw",1,"")')
  call feedkeys( g:speech#leader_key . 'w', 't')
endfunction


" FUNCTION Ignore
" Transform <CR> into '' to avoid undesired 
" adding of text into the command line if <CR> not finish
" the command mode.
"
function! speech#command_line#Ignore()
  return ''
endfunction

" FUNCTION StartSearch
"
function! speech#command_line#StartSearch(key)
  let s:command_line_mode = '/'

  call speech#sound#Play('search.wav')

  " Clear error and warning string to catch new values
  let s:prev_errmsg = v:errmsg
  let v:errmsg = '' 
  let s:prev_warningmsg = v:warningmsg
  let v:warningmsg = '' 

  return a:key
endfunction
