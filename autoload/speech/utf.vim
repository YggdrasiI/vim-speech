" SECTION String functions which respects the encoding of UTF-8 files.


" FUNCTION StringLength
" The default VIM function, strlen, does not respect multibyte characters. This function does.
"
function! speech#utf#StringLength(str)
	let len = strlen(substitute(a:str, ".", "x", "g"))
	return l:len
endfunction


" FUNCTION StringLength2
" Decide if a string contains a single unicode character.
" The number of bytes is encoded as max(1,number of leading 1 bits), see
" https://en.wikipedia.org/wiki/UTF-8#Description
" The difference between strlen() and the unicode string length is
" the number of bytes with 10xx xxxx coding.
" Note: This variant is slower as StringLength().
"
function! speech#utf#StringLength(str)
	let l:len = len(a:str)
  if has("multi_byte_encoding") == 0
		return l:len
	endif
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


" FUNCTION IsSingleCharacter
" Return true if str ist one character. Respect multi byte
" characters.
" Respect RFC 3629, thus a character is at most four bytes wide.
"
function! speech#utf#IsSingleCharacter(str)
	let l:len = len(a:str)
	if l:len < 2
		return l:len " 0 or 1
	endif
  if has("multi_byte_encoding") == 0
		return 0
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


