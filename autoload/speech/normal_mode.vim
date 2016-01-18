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
let s:FindChar_key_combination = "\<plug>\<C-N>\<C-6>"

" FUNCTION FindChar
" Fetch and process char for f{char}, etc.
"
function! speech#normal_mode#FindChar(invoke_char)
  let c = nr2char(getchar())

  " Second approach. Invoke VIM's normal action
  " and finally call own <expr>-key combination.
  " Note that this require a split into two feedkeys calls.
  " One without key remapping and one with remapping.
  " Otherwise an infinite loop occour!
  let s:FindChar_currentCol = col(".")
  call feedkeys(a:invoke_char . l:c, 'n')
  call feedkeys(s:FindChar_key_combination, 't')
endfunction

" FUNCTION FindCharRepeat
" Same like FindChar but without reading of
" operator (getchar-call)
"
function! speech#normal_mode#FindCharRepeat(invoke_char)
  let s:FindChar_currentCol = col(".")
  call feedkeys(a:invoke_char, 'n')
  call feedkeys(s:FindChar_key_combination, 't')
endfunction

" FUNCTION FindCharPart2
" Speech current word if 'f{char}' (and similar) movement found matching
" character.
" Note: Used as expression. Cursor movement not allowed.
" 
function! speech#normal_mode#FindCharPart2()
  let l:cursor_moved = 0
  if col(".") != s:FindChar_currentCol
    let l:cursor_moved = 1
  endif
  let s:FindChar_currentCol = -1

  if l:cursor_moved
    " Send key combination to speak out current word.
    return g:speech#leader_key . 'w'
  else
    " Play error sound
    call speech#sound#Error()
  endif
  return '' 
endfunction
