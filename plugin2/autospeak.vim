" HEADLINE Collection of scripts for speech feedback on several vim actions

" SECTION Key movements in normal mode and visual mode
" This script trys to analyse the cursor movement
" and spells out the current char, word or WORD
" For words with length 1 (i.e. special characters)
" the character will be translate into the character name

" Options:
" Each option name begins with AS_.
" AS_vertical defines the output for vertical line changes
" Possible values: line, pos, posw, posW, word, char TODO
let s:AS_vertical = 'linenumber'

" AS_char defines the output for charwise, horizontal cursor change.
" Possible values: linenumber, word, char
let s:AS_char = 'char'

" AS_word defines the output for wordwise, horizontal cursor change.
" Note: Words of length 1 (special character like period) will be
" handled by the algorithm for special characters.
let s:AS_word = 'word'

" Autospeak can be used in normal and visual mode.
" Set AS_modes to 'nv' to enable autospeak in both modes
" Let the option empty to disable autospeak.
let s:AS_modes = 'nv'

" Save output of commands in a variable
redir => g:messbuf
"nnoremap <silent> : :execute 'redir END | echon g:messbuf | redir => g:messbuf":


" FUNCTION Just for Testing
function! HoldEvent()
	call Checkmode('')
	echo 'hold event'
endfunction


"autocmd CursorMoved,BufLeave * call Checkmode("")
autocmd InsertLeave * call Checkmode('n')
autocmd InsertEnter * call Checkmode('i')
"autocmd CmdwinLeave * call Checkmode('')
autocmd CursorMoved,BufEnter,BufLeave * call Checkmode('')
autocmd BufwinEnter * call Checkmode('')

" Note: This is only useful if updatetimes is very short
"autocmd CursorHold * call HoldEvent()


" SUBSECTION Old approaches
"autocmd BufNewFile * call Espeak('New file ' . expand("%:t") )
"autocmd BufNewFile * call Sfilename()
"autocmd CmdwinEnter * call Sget_mode('c')
"autocmd InsertEnter * call Sget_mode('i')
"autocmd CmdwinLeave * call Sget_mode('n')
"autocmd InsertLeave * call Sget_mode(mode(0))
"autocmd CursorMoved * call Autospeak()


