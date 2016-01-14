" SECTION Filter functions to convert text. 
" This could be usefull to spell words with different variations,
" in Example to vocalize each character of a word separatly.

" FUNCTION FilterLinebreaks
"
function! speech#filter#FilterLinebreaks(text)
	"return shellescape(tr(a:text, "\n\r", '  '))
	"return escape(tr(a:text, "\n\r", '  '), "\"'\\!")
	"return escape(tr(a:text, "\n\r", '  '), "\"\\!")
	return tr(a:text, "\n\r", '  ')
endfunction

" FUNCTION FilterSplitCharacters
" Insert argument split_string after each character of text
" This should be used in combination with the spelling of special characters.
"
function! speech#filter#FilterSplitCharacters(text, split_string)
	let text = substitute(a:text, "\\\(.\\\)", "\\1" . a:split_string, "g")
	return l:text
endfunction

" FUNCTION FilterSingleCharactersOld
"
function! speech#filter#FilterSingleCharactersOld(text, spellSpace)
	let text = a:text
	" Substitute template
	"let text = substitute(l:text, "\\\(\[\]\\\)", '  ', 'g')
	
	if g:speech#language == 'de'
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


" FUNCTION FilterSingleCharacters
" 
function! speech#filter#FilterSingleCharacters(text, spellSpace)
	let l:text = a:text
	let l:lang = g:speech#language
	let l:characters = g:vs_characters

	"if strchars(l:text) == 1 " Note that strlen does not work for multibyte characters
	if speech#utf#IsSingleCharacter(l:text)
		" Omit for loop and made direct lookup into the directory of special
		" characters.
		let l:char_names = get(l:characters, l:text[0], 0)
		if type(l:char_names) == 4
			return get(l:char_names, l:lang, l:text . ' vim-speech: character not found. ')
		endif
	endif

	if a:spellSpace == 1
		let l:text = substitute(l:text, "\\\(\[ \]\\\)", ' ' . speech#locale#GetToken(' ')  . ' ', 'g')
	endif

	for l:char in values(l:characters)
		let l:text = substitute(l:text, char['regex'], ' ' . get(l:char, l:lang,'undefined') . ' ', 'g')
	endfor
	
	return l:text
endfunction


" FUNCTION FilterQuotes
"
function! speech#filter#FilterQuotes(text, spellSpace)
	let text = a:text
	
	if g:speech#language == 'de'
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


" FUNCTION SplitWords
" Add extra spaces at some positions to omit
" the supression of spelling special characters.
" Example error without this filter: In the string
" '/dev/null' only the first ' will be spelled out. 
" 
function! speech#filter#SplitWords(text)
	let text = substitute(a:text, "'", " ' ", "g")
	"let text = substitute(a:text, "\$#", "\$ #", "g")
	let text = substitute(a:text, "#", " # ", "g")
	let text = substitute(a:text, ";", " ; ", "g")

	return l:text
endfunction


