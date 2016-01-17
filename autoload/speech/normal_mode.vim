" FUNCTION RestorePreviousSelection
" Wrap gv command which restores the previous visual selection
" 
function! speech#normal_mode#RestorePreviousSelection()
  "call Espeak( speech#locale#GetToken('selection_restore') )
  " or
  call speech#general#PingMode(visualmode())
  return 'gv'
endfunction


" SECTION Handler for remapping of f, F, t, T, colon and semicolon.

" FUNCTION InputChar
" Fetch and process char for f{char}, etc.
"
function! speech#normal_mode#FindChar(invoke_char)
  let c = nr2char(getchar())
  call feedkeys(a:invoke_char . c, 'nt')

  " Check if cursor is now on requested character.
  " Hm, this checks cursor position too early.
  if getline('.')[col('.') - 1] ==? c
    " Speak out current word.
    call speech#PreserveCursor('call speech#Movement("yiw",0,"")')
  else
    " Play error sound
    call speech#sound#Error()
  endif

endfunction
