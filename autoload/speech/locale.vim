" SECTION Related files
" plugin2/languagetoken.vim


" SECTION Functions

" FUNCTION GetToken
" Return token for selected language.
"
function! speech#locale#GetToken(token)
  return get( get( g:vs_langs, a:token, {}), g:speech#language,
        \ 'Undefined token '.a:token.' ')
endfunction
