" FUNCTION Play
" Call external audio player to play file.
"
function! speech#sound#Play(filename)
  let l:path = g:speech#root_dir . 'sounds/' . a:filename
  "Note: Path should not contain the tilde as shortcut for $HOME.
  " It would not be resolved for paths sourounded by quotes.
  
  call system('aplay "'. l:path . '" 1&> /dev/null &')
  "redraw!
endfunction



