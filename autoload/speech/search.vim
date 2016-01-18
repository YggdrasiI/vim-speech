" FUNCTION StartSearch
"
function! speech#search#StartSearch(key)
  call speech#sound#Play('search.wav')
  return a:key
endfunction
