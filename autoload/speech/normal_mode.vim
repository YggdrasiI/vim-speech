" FUNCTION RestorePreviousSelection
" Wrap gv command which restores the previous visual selection
" 
function! speech#normal_mode#RestorePreviousSelection()
  "call Espeak( speech#locale#GetToken('selection_restore') )
  " or
  call speech#general#PingMode(visualmode())
  return 'gv'
endfunction
