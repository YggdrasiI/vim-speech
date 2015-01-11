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

" FUNCTION Check if mode differs from previous and 
" give accoustic feedback for changes. 
" If the input argument is empty it will automatically detect the current
" mode.
let g:vs_last_mode = ''
let g:vs_last_buffer = -1
function! Checkmode(mode)
	if a:mode == ''
		let l:cur_mode = mode()
	else
		let l:cur_mode = a:mode
	endif
	let cur_buffer = bufnr("")

	"echom 'Modes: ' . g:vs_last_mode . ', ' . l:cur_mode 
	if g:vs_last_mode ==# l:cur_mode && g:vs_last_buffer == l:cur_buffer
		return
	endif

	let l:mode_text = ''
	if g:vs_last_mode !=# l:cur_mode
		" Call transition handler
		"
		"
		let g:vs_last_mode = l:cur_mode	
		"let l:mode_text .= 'Mode ' . l:cur_mode . '. '
		call Sping_mode(l:cur_mode)
	endif

	if g:vs_last_buffer != l:cur_buffer 
		let bufname = bufname(l:cur_buffer)
		if l:bufname == ''
			let l:mode_text .= 'Unnamed Buffer. '
		elseif l:bufname == '[Command Line]'
			let l:mode_text .= 'Command Buffer. '
			let l:cur_buffer = -1
		else
			let l:mode_text .= 'Buffer ' . fnamemodify(l:bufname,":p:t") . '. '
			"let l:mode_text .= 'Buffer ' . l:bufname . '. '
		endif
	endif

	if g:vs_last_buffer != -1
		call Espeak( l:mode_text )
	else
		"Check :messages buffer
		if l:cur_mode == 'n'
			redir END
			if g:messbuf != '' 
				let mess = split(g:messbuf,"\n")
				if len(l:mess) > 1
					"call Espeak( l:mess[0] )
					call Espeak( 'Ende eines Befehls' )
					"echon 'Nachricht:' . l:mess[0] . 'END'
				endif
			endif
			redir => g:messbuf
		endif
	endif

	let g:vs_last_buffer = l:cur_buffer	

endfunction

let Ssound_prefix = '${HOME}/.vim/bundle/vim-speech/sounds/'
function! Ssound(filename) 
	let l:path = g:Ssound_prefix . a:filename
	call system('aplay "'. l:path . '" 1&> /dev/null &') 
	redraw!
endfunction

function! Sping_mode(mode)
	echom a:mode
	if a:mode[0] == 'i'
		let mode_text = 'Insert Mode'
		let filename = 'mode_insert.wav'
	elseif a:mode[0] == 'c'
		let mode_text = 'Command Mode'
		let filename = 'mode_command.wav'
	elseif a:mode[0] == 'v'
		let mode_text = 'Visual Mode'
		let filename = 'vim_visual1.wav'
	elseif a:mode[0] == 'V'
		let mode_text = 'Visual Line Mode'
		let filename = 'vim_visual2.wav'
	elseif a:mode[0] == "\<C-V>"
		let mode_text = 'Visual Block Mode'
		let filename = 'vim_visual3.wav'
	else
		let mode_text = 'Normal Mode'
		let filename = 'mode_normal.wav'
	endif

	"extra check to distict normal mode 
	"in command line buffer from other buffers
	if bufname("") == '[Command Line]'
		let filename = 'mode_command.wav'
	endif

	call Ssound(l:filename)
endfunction




"autocmd CursorMoved,BufLeave * call Checkmode("")
autocmd InsertLeave * call Checkmode('n')
autocmd InsertEnter * call Checkmode('i')
"autocmd CmdwinLeave * call Checkmode('')
autocmd CursorMoved,BufEnter,BufLeave * call Checkmode('')
autocmd BufwinEnter * call Checkmode('')


" SUBSECTION Old approaches
"autocmd BufNewFile * call Espeak('New file ' . expand("%:t") )
"autocmd BufNewFile * call Sfilename()
"autocmd CmdwinEnter * call Sget_mode('c')
"autocmd InsertEnter * call Sget_mode('i')
"autocmd CmdwinLeave * call Sget_mode('n')
"autocmd InsertLeave * call Sget_mode(mode(0))
"autocmd CursorMoved * call Autospeak()


