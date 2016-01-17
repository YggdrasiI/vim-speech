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
function! speech#normal_mode#FindChar(invoke_char, offset)
  let c = nr2char(getchar())
  "let l:spell_word = ":\<C-U>call speech#PreserveCursor('call speech#Movement(\"yiw\",0,\"\")')\<CR>"
  let l:spell_word = ":\<C-U>call speech#normal_mode#FindCharPart2(\""
        \ . escape(l:c, '"') . '",' . a:offset . ")\<CR>"
  
  call feedkeys(a:invoke_char . l:c . l:spell_word, 'nt')
endfunction

function! speech#normal_mode#FindCharPart2(invoke_char, offset)
  " Check if cursor is now on requested character.
  if getline('.')[col('.') - 1 + a:offset] ==? a:invoke_char
    " Speak out current word.
    call speech#PreserveCursor('call speech#Movement("yiw",0,"")')
  else
    " Play error sound
    call speech#sound#Error()
  endif
endfunction
