" SECTION General helper functions
" Get current visual selection (during visual mode)
" or content of last visual selection (during other modes)
function! Get_current_visual_selection()
	if -1 ==# index(['v','V',"\<C-V>"], mode(0))
		let posA = getpos("'<")[1:2]
		let posB = getpos("'>")[1:2]
	else
		let posA = getpos("v")[1:2]
		let posB = getpos(".")[1:2]
		if posA[0] > posB[0] || ( posA[0] == posB[0] && posA[1] > posB[1] )
			let	[posA, posB] = [l:posB, l:posA]
		endif
	endif

	if 'v' == mode(0)
		let lines = getline(posA[0], posB[0])
		let lines[-1] = lines[-1][: posB[1] - (&selection == 'inclusive' ? 1 : 2)]
		let lines[0] = lines[0][posA[1] - 1:]
		let selection_text = join(lines, "\n")
		let selection_range =  [posA, posB]
	elseif 'V' == mode(0)
		let lines = getline(posA[0], posB[0])
		"let number_of_lines = posB[0]-posA[0]+1
		"return ( number_of_lines . ( number_of_lines==1? ' Zeile. ' : ' Zeilen. ') )
		let selection_text = join(lines, "\n")
		let selection_range =  [[posA[0], 0], [posB, len(lines[-1])] ]
	elseif "\<C-V>" == mode(0)
		let lines = getline(posA[0], posB[0])
		let [col_left, col_right] = [posA[1]-1, posB[1]-1]
		if posA[1] > posB[1]
			let [col_left, col_right] = [posB[1]-1, posA[1]-1]
		endif
		let blocks = []
		for l in lines
			" The following block selection does not respect the problems due the
			" usage of tabulators. TODO: Respect width of tabs to determine
			" blockwidth for each line. 
			let blocks += [ l[ l:col_left : l:col_right ]	]
		endfor
		let selection_text = join(l:blocks, "\n")
		let selection_range =  [[posA[0], col_left], [posB, col_right]]
	endif
	return ([selection_text, selection_range])
endfunction

" SECTION Filter functions to convert text. 
" This could be usefull to spell words with different variations,
" in Example to vocalize each character of a word separatly.

function! Sfilter_linebreaks(text)
	"return shellescape(tr(a:text, "\n\r", '  '))
	"return escape(tr(a:text, "\n\r", '  '), "\"'\\!")
	"return escape(tr(a:text, "\n\r", '  '), "\"\\!")
	return tr(a:text, "\n\r", '  ')
endfunction

" Insert argument split_string after each character of text
" This should be used in combination with the spelling of special characters.
function! Vimspeak_filter_split_characters(text, split_string)
	let text = substitute(a:text, "\\\(.\\\)", "\\1" . a:split_string, "g")
	return l:text
endfunction

function! Vimspeak_filter_single_charactersOld(text, spellSpace)
	let text = a:text
	" Substitute template
	"let text = substitute(l:text, "\\\(\[\]\\\)", '  ', 'g')
	
	if g:espeak_language == 'de'
		" Substitute by german words
		if a:spellSpace == 1
			let text = substitute(l:text, "\\\(\[ \]\\\)", ' Leerzeichen ', 'g')
		endif
		let text = substitute(l:text, "\\\(\[\\t\]\\\)", ' Tabulator ', 'g')
		let text = substitute(l:text, "\\\(\[(\]\\\)", ' Klammer auf ', 'g')
		let text = substitute(l:text, "\\\(\[)\]\\\)", ' Klammer zu ', 'g')
		let text = substitute(l:text, "\\\(\[{\]\\\)", ' Geschwungene Klammer auf ', 'g')
		let text = substitute(l:text, "\\\(\[}\]\\\)", ' Geschwungene Klammer zu ', 'g')
		let text = substitute(l:text, "\\\(\[<\]\\\)", ' Spitze Klammer auf ', 'g')
		let text = substitute(l:text, "\\\(\[>\]\\\)", ' Spitze Klammer zu ', 'g')
		let text = substitute(l:text, "\\\(\[\"\]\\\)", ' Doppeltes Anführungszeichen ', 'g')
		let text = substitute(l:text, "\\\(\['\]\\\)", ' Einfaches Anführungszeichen ', 'g')
		let text = substitute(l:text, "\\\(\[.\]\\\)", ' Punkt ', 'g')
		let text = substitute(l:text, "\\\(\[,\]\\\)", ' Komma ', 'g')
		let text = substitute(l:text, "\\\(\[:\]\\\)", ' Doppelpunkt ', 'g')
		let text = substitute(l:text, "\\\(\[;\]\\\)", ' Semikolon ', 'g')
		let text = substitute(l:text, "\\\(\[-\]\\\)", ' Bindestrich ', 'g')
		let text = substitute(l:text, "\\\(\[`\]\\\)", ' Gravis ', 'g')
		let text = substitute(l:text, "\\\(\[!\]\\\)", ' Ausrufezeichen ', 'g')
		let text = substitute(l:text, "\\\(\[?\]\\\)", ' Fragezeichen ', 'g')
		let text = substitute(l:text, "\\\(\[\n\r\]\{1,2\}\\\)", ' Zeilenumbruch ', 'g')
		let text = substitute(l:text, "\\\(\[\[\]\\\)", ' Eckige Klammer auf', 'g')
		let text = substitute(l:text, "\\\(\[\\\]\]\\\)", ' Eckige Klammer zu', 'g')
		let text = substitute(l:text, "\\\(\[\\\\\]\\\)", ' Backslash ', 'g')
		let text = substitute(l:text, "\\\(\[\/\]\\\)", ' Slash ', 'g')
		let text = substitute(l:text, "\\\(\[#\]\\\)", ' Raute ', 'g')
	else
		" Substitute by english words
		if a:spellSpace == 1
			let text = substitute(l:text, "\\\(\[ \]\\\)", ' space ', 'g')
		endif
		let text = substitute(l:text, "\\\(\[\\t\]\\\)", ' tabulator ', 'g')
		let text = substitute(l:text, "\\\(\[(\]\\\)", ' left paranthese ', 'g')
		let text = substitute(l:text, "\\\(\[)\]\\\)", ' right paranthese ', 'g')
		let text = substitute(l:text, "\\\(\[{\]\\\)", ' left brace ', 'g')
		let text = substitute(l:text, "\\\(\[}\]\\\)", ' right brace ', 'g')
		let text = substitute(l:text, "\\\(\[<\]\\\)", ' left chevron ', 'g')
		let text = substitute(l:text, "\\\(\[>\]\\\)", ' right chevron ', 'g')
		let text = substitute(l:text, "\\\(\[\"\]\\\)", ' double quote ', 'g')
		let text = substitute(l:text, "\\\(\['\]\\\)", ' single quote ', 'g')
		let text = substitute(l:text, "\\\(\[.\]\\\)", ' dot ', 'g')
		let text = substitute(l:text, "\\\(\[,\]\\\)", ' comma ', 'g')
		let text = substitute(l:text, "\\\(\[:\]\\\)", ' colon ', 'g')
		let text = substitute(l:text, "\\\(\[;\]\\\)", ' semicolon ', 'g')
		let text = substitute(l:text, "\\\(\[-\]\\\)", ' hyphen ', 'g')
		let text = substitute(l:text, "\\\(\[`\]\\\)", ' back-tick ', 'g')
		let text = substitute(l:text, "\\\(\[!\]\\\)", ' bang ', 'g') " or exclamation mark
		let text = substitute(l:text, "\\\(\[?\]\\\)", ' question mark ', 'g') 
		let text = substitute(l:text, "\\\(\[\n\r\]\{1,2\}\\\)", ' new line ', 'g')
		let text = substitute(l:text, "\\\(\[\[\]\\\)", ' left bracket ', 'g')
		let text = substitute(l:text, "\\\(\[\\\]\]\\\)", ' right bracket ', 'g')
		let text = substitute(l:text, "\\\(\[\\\\\]\\\)", ' backslash ', 'g')
		let text = substitute(l:text, "\\\(\[\/\]\\\)", ' slash ', 'g')
		let text = substitute(l:text, "\\\(\[#\]\\\)", ' hashtag ', 'g')
	endif

	return l:text
endfunction

function! Vimspeak_filter_single_characters(text, spellSpace)
	let l:text = a:text
	let l:lang = g:espeak_language
	let l:characters = g:vs_characters

	"if strchars(l:text) == 1 " Note that strlen does not work for multibyte characters
	if Utf_single_character(l:text)
		" Omit for loop and made direct lookup into the directory of special
		" characters.
		let l:char_names = get(l:characters, l:text[0], 0)
		if type(l:char_names) == 4
			return get(l:char_names, l:lang, l:text . ' vimspeech: not found ')
		endif
	endif

	if a:spellSpace == 1
		let l:text = substitute(l:text, "\\\(\[ \]\\\)", ' ' . VimspeakLocaleToken(' ')  . ' ', 'g')
	endif

	for l:char in values(l:characters)
		let l:text = substitute(l:text, char['regex'], ' ' . get(l:char, l:lang,'undefined') . ' ', 'g')
	endfor
	
	return l:text
endfunction

function! Vimspeak_filter_quotes(text, spellSpace)
	let text = a:text
	
	if g:espeak_language == 'de'
		" Substitute by german words
		let text = substitute(l:text, "\\\(\[\"\]\\\)", ' Doppeltes Anführungszeichen ', 'g')
		let text = substitute(l:text, "\\\(\['\]\\\)", ' Einfaches Anführungszeichen ', 'g')
	else
		" Substitute by english words
		let text = substitute(l:text, "\\\(\[\"\]\\\)", ' double quote ', 'g')
		let text = substitute(l:text, "\\\(\['\]\\\)", ' single quote ', 'g')
	endif

	return l:text
endfunction

"Add extra spaces at some positions to omit
"the supression of spelling special characters.
"Example error without this filter: In the string
" '/dev/null' only the first ' will be spelled out. 
function! Sfilter_splitWords(text)
	let text = substitute(a:text, "'", " ' ", "g")
	"let text = substitute(a:text, "\$#", "\$ #", "g")
	let text = substitute(a:text, "#", " # ", "g")
	let text = substitute(a:text, ";", " ; ", "g")

	return l:text
endfunction

" FUNCTION Utf_strlen
" strlen does not respect multibyte characters. This function does.
function! Utf_strlen(str)
	let len = strlen(substitute(a:str, ".", "x", "g"))
	return l:len
endfunction

"FUNCTION Decide if a string contains a single unicode character.
" The number of bytes is encoded as max(1,number of leading 1 bits), see
" https://en.wikipedia.org/wiki/UTF-8#Description
" The difference between strlen() and the unicode string length is
" the number of bytes with 10xx xxxx coding.
" Note: This variant is slower as Utf_strlen().
function! Utf_strlen2(str)
	let l:len = len(a:str)
	let l:subbytes = 0
	let l:i = l:len - 1
	while l:i
		if char2nr(a:str[l:i])/64 == 2  " 10xxxxxx
			let l:subbytes = l:subbytes + 1
		endif
		let l:i = l:i -1
	endwhile
	return l:len - l:subbytes
endfunction

" Respect RFC 3629, thus a character is at most four bytes wide.
function! Utf_single_character(str)
	let l:len = len(a:str)
	if l:len < 2
		return l:len " 0 or 1
	endif
	"let l:second_byte = char2nr(a:str[1]) 
	"if l:second_byte > 127
	"	if l:second_byte > 191 " Begin of second char
	"		return 0 
	"	endif
	let l:first_byte = char2nr(a:str[0])  " 11xx yyyy
	let l:width = first_byte/16 - 10 			" 2-4
	return l:width == l:len
endfunction


" FUNCTION call external audio player to play file
let Ssound_prefix = '${HOME}/.vim/bundle/vim-speech/sounds/'
function! Ssound(filename)
	let l:path = g:Ssound_prefix . a:filename
	call system('aplay "'. l:path . '" 1&> /dev/null &')
	"redraw!
endfunction


" FUNCTION Generate audio feedback for current VIM mode.
function! Sping_mode(mode)
	if a:mode[0] ==# 'i'
		let mode_text = 'Insert Mode'
		let filename = 'mode_insert.wav'
	elseif a:mode[0] ==# 'c'
		let mode_text = 'Command Mode'
		let filename = 'mode_command.wav'
	elseif a:mode[0] ==# 'v'
		let mode_text = 'Visual Mode'
		let filename = 'vim_visual1.wav'
	elseif a:mode[0] ==# 'V'
		let mode_text = 'Visual Line Mode'
		let filename = 'vim_visual2.wav'
	elseif a:mode[0] ==# "\<C-V>"
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

	echom l:filename
	call Ssound(l:filename)
endfunction


" FUNCTION Check if current mode differs from previous and
" give accoustic feedback for changes.
" If the input argument is empty it will automatically detect the current
" mode.
let g:vs_last_mode = ''
let g:vs_last_buffer = -1
function! Checkmode(mode)
	if a:mode ==# ''
		let l:cur_mode = mode()
	elseif a:mode ==# 'x'
		" Force change
		let g:vs_last_mode = 'x'
		let l:cur_mode = mode()
	else
		let l:cur_mode = a:mode
	endif
	let cur_buffer = bufnr("")

	if g:vs_last_mode ==# l:cur_mode && g:vs_last_buffer == l:cur_buffer
		return
	endif

	let l:mode_text = ''
	if g:vs_last_buffer != l:cur_buffer
		let bufname = bufname(l:cur_buffer)
		if l:bufname == ''
			let l:mode_text .= 'Unnamed Buffer. '
		elseif l:bufname == '[Command Line]'
			let l:mode_text .= 'Command Buffer. '
			let l:cur_buffer = -1
		else
			let l:mode_text .= 'Buffer ' . fnamemodify(l:bufname,":p:t") . '. '
		endif

		if g:vs_last_buffer != -1
			call Espeak( l:mode_text )
		endif

	elseif g:vs_last_mode !=# l:cur_mode
		"let l:mode_text .= 'Mode ' . l:cur_mode . '. '
		call Sping_mode(l:cur_mode)

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

	let g:vs_last_mode = l:cur_mode
	let g:vs_last_buffer = l:cur_buffer

endfunction

