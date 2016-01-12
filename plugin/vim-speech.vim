" HEADLINE Global values

" SECTION Set global options of Espeak
" Used language
let g:espeak_language = 'en'
"let g:espeak_language = 'de'

" Other option of espeak
let g:espeak_options = '-k 30 -s 140 -a 100'

" SECTION Vim-speech variables
" This enable/disable vimspeech.
"let g:vimspeech = 1

" Root directory required to find sound snipets.
let g:vimspeech_root_dir = '~/.vim/bundle/vim-speech/'

" Flag to surpress all audio out
let g:vimspeech_silent = 0

if exists("*VimSpeech_Load") == 0
	function! VimSpeech_Load()
		" Load files from the plugin2 directory.
		" The files from plugin2 are not placed in this folder
		" to guarantee the right loading order. Moreover, this
		" allows an easy reload of the whole plug-in during a VIM session
		let g:vimspeech=1
		let g:vimspeech_enabled=1
		execute 'source ' . g:vimspeech_root_dir . 'plugin/vim-speech.vim'
	endfunction
endif

function! VimSpeech_Active()
	if exists("g:vimspeech") && g:vimspeech == 1
		return 1
	endif
	return 0
endfunction

" SECTION Definition of speech engine calls.
" Every text which should be spoken will call the function VimSpeech_Speak.
" This function uses the global variable g:vimspeech_engine to select one
" of the given engines.
" Call TODO vimspeech_engines() to get a list of available engines.

" FUNCTION VimSpeech_list_engines
function! VimSpeech_list_engines() 
	let engines = 'Espeak, '
	let text = printf( VimspeakLocaleToken('available_speech_engines'), l:engines )
	call Espeak(l:text)
endfunction

" FUNCTION VimSpeech_Speak
" Push text to currently selected speech engine over a system call.
" The following functions of this section defines the available targets 
" of this function. Currently, only Espeak is supported. 
function! VimSpeech_Speak(text) 
	if g:vimspeech_silent
		return
	endif
	if g:vimspeech_engine == 'Espeak'
		call Espeak(a:text)
	endif
endfunction

" FUNCTION Espeak
" Kill running instances of espeak and create new one.
" 
function! Espeak(text) 
	call system('killall espeak ; espeak -v'.g:espeak_language . ' ' . g:espeak_options . '  "' . a:text . '" 1&> /dev/null &')
	"redraw!
	echom a:text
	"echom tr(a:text,"\n",' ')[0:30]
endfunction

" FUNCTION Picospeech
" Like Espeak function but for picospeech enigne.
" 
function! Picospeech(text) 
	call system(' killall aplay ; killall testtts ;')
	call system('picospeech -l ' . g:espeak_language . ' "' . a:text . '" &')
endfunction

" SECTION Unnamed section
" FUNCTION Speech information about a VIM range.
function! Srange() range
	if a:firstline == a:lastline
		let msg = VimspeakLocaleToken('line') . a:firstline 
	else
		let msg = printf( VimspeakLocaleToken('selection_line_range'), a:firstline, a:lastline )
	endif
	call Espeak (l:msg)
endfunction

" FUNCTION Get line number of cursor 
function! Slinenumber()
	call Espeak ( line(".") )
endfunction

" FUNCTION Get position of cursor
function! Sposition()
	let curpos = getpos(".")
	let msg = VimspeakLocaleToken('line') . l:curpos[1] .
				\ VimspeakLocaleToken('character') . l:curpos[2]
	silent! call Espeak ( l:msg )
endfunction

" FUNCTION Speech of filename.
function! Sfilename()
	let msg = printf( VimspeakLocaleToken('filename'), expand("%:t") )
	call Espeak (l:msg)
endfunction

" FUNCTION Speech next n lines.
function! Sline(count1) 
	"execute 'normal! "s' . max([1,a:count]) . 'yy'
	let curpos = getpos(".")
	"execute '' . l:curpos[1] . ',' . (l:curpos[1] + a:count1 - 1) . 'yank s'
	"let msg = Sfilter_linebreaks(@s)
	let l:msg = join(getline(l:curpos[1] , l:curpos[1] + a:count1 - 1),' ')
	let l:msg = Sfilter_linebreaks(l:msg)
	"let msg = Sfilter_splitWords(l:msg)

	let msg = Vimspeak_filter_single_characters(l:msg, 0)

	call Espeak (l:msg)
	"echon ' ' . l:msg
	return ''
endfunction

" FUNCTION Speech next n words.
function! Sword(count) 
	call Smotion(a:count, "w", "b")
	"let wordUnderCursor = expand("<cword>")
endfunction

" FUNCTION Speech next n WORDS (uppercase motion).
function! SWord(count) 
	call Smotion(a:count, "W", "b")
	"let wordUnderCursor = expand("<cWORD>")
endfunction

" FUNCTION Speech character under the cursor.
function! Schar(count) 
	let curpos = getpos(".")
	execute 'normal! "sy'. max([1,a:count]) . 'k'
	let text = Vimspeak_filter_single_characters(@s, 1)
	call Espeak ( Sfilter_linebreaks(l:text) )
	call setpos (".", l:curpos )
endfunction

" FUNCTION Wrap function call to
" save current cursor position (cursor move to line start on buffer switch)
" and omit sound during handling
" Note: The following approach should working, too. 
" let l:curpos = getpos("`s")
"	[cursor movements]
"	call setpos ("'s", l:curpos )
" Note: The following approach does not work for all yanking movements:
" let l:curpos = getpos(".")
"	[cursor movements]
"	call setpos (".", l:curpos )
"
function! Spreserve_cursor(handler)
	let l:view = winsaveview()
	let g:vimspeech_silent = 1

	execute a:handler

	let g:vimspeech_silent = 0
	call winrestview(l:view)
	"return ''
endfunction


" FUNCTION Wrapper for visual mode
function! Spreserve_cursor_visual(handler,movement)
	let g:vimspeech_silent = 1
	execute a:handler
	let g:vimspeech_silent = 0
	return a:movement
endfunction

" FUNCTION Speech text between current cursor position and the position after
" the given movement.
function! Smovement(movement, count, filter)
	let l:backup = @"
	let l:backup_register_s = @s
	if a:count > 0
		execute 'normal! "s'. a:count . a:movement
	else
		execute 'normal! "s' . a:movement
	endif
	let l:msg = @s
	let @s = l:backup_register_s

	if a:filter != ''
		execute 'let l:msg = ' . a:filter . '(l:msg)'
	endif

	let l:msg = Sfilter_linebreaks(l:msg)

	if Utf_is_single_character(l:msg) == 1
		let l:msg = Vimspeak_filter_single_characters(l:msg, 1)
	else
		" Just for testing. Should be optional
		let l:msg = Vimspeak_filter_single_characters(l:msg, 0)
	endif

	let msg = Vimspeak_filter_quotes(l:msg, 0)

	let g:vimspeech_silent = 0
	call Espeak(l:msg)
	let @" = l:backup
	return ''
endfunction

" Visual mode require other approach
function! Svmovement(movement, count, filter)
	let msg = @*	
	if len(l:msg) == 1
		let msg = Vimspeak_filter_single_characters(l:msg)
	endif
	if a:filter != ''
		execute 'call ' . a:filter . '(l:msg)'
	endif
	"echo l:msg
	let g:vimspeech_silent = 0
	call Espeak(l:msg)
	"silent! 'normal! gv'
	"return ''
endfunction

function! Svmovement2(movement, count, filter)
	if len(@*) == 1
		let @s = Vimspeak_filter_single_characters(@*, 1)
	endif
	if a:filter != ''
		execute 'call ' . filter . '(@*)'
	endif
	let g:vimspeech_silent = 0
	call Espeak(@s)
	"silent! 'normal! gv'
	"return ''
endfunction

function! Smotion(count, motion, premove) 

	let curpos = getpos(".")
	let nbr = max([1,a:count])

	" Optional move to begin of word
	if a:premove == "b"
		call feedkeys('wb', 'n') " ignore remapping of w,b
	endif

	execute 'norm! "sy' . l:nbr . a:motion
	call setpos (".", l:curpos )

	let msg = Sfilter_linebreaks(@s)
	if len(l:msg) == 1
		let msg = Vimspeak_filter_single_characters(@s, 1)
		"echo 'Zeichen ' . l:msg
		call Espeak (l:msg )
	else
		echo l:msg
		call Espeak (l:msg)
	endif
endfunction

" FUNCTION Old / Veraltet
function! Sdetect_visual_mode()
    let m = visualmode()
    if m ==# 'v'
        call Espeak('character-wise visual mode')
    elseif m == 'V'
        call Espeak('line-wise visual mode')
    elseif m == "\<C-V>"
        call Espeak('block-wise visual mode')
    endif
		" Restore visual mode
		normal! gv
endfunction

" FUNCTION 
function! Scmd_test(text)
	let cmd = getcmdline()
	let msg = Sfilter_linebreaks(a:text)
	call Espeak(l:msg)
	"<C-\>eescape(getcmdline(), ' \')<CR>
 return l:cmd
endfunction

" FUNCTION Map mode keyword on effable text.
function! Sget_mode(mode)
	if a:mode[0] == 'i'
		let mode_text = 'Insert Mode'
	elseif a:mode[0] == 'c'
		let mode_text = 'Command Mode'
	elseif a:mode[0] == 'v'
		let mode_text = 'Visual Mode'
	elseif a:mode[0] == 'V'
		let mode_text = 'Visual Line Mode'
	elseif a:mode[0] == "\<C-V>"
		let mode_text = 'Visual Block Mode'
	elseif a:mode[0] == 'n'
		let mode_text = 'Normal Mode'
	else
		let mode_text = 'Unknown Mode'
	endif

	"extra check to distict normal mode 
	"in command line buffer from other buffers
	if bufname("") == '[Command Line]'
		call Espeak( l:mode_text . ' in Command Line')
	else
		call Espeak( l:mode_text )
	endif

return ''
endfunction



" Surpress automatic loading if vimspeech variable is missing or not 1.
if VimSpeech_Active() == 0
	let g:vimspeech = 0
	:finish
else
	"call VimSpeech_Load()
	execute 'source ' . g:vimspeech_root_dir . 'plugin2/languagetoken.vim'
	execute 'source ' . g:vimspeech_root_dir . 'plugin2/functions.vim'
	execute 'source ' . g:vimspeech_root_dir . 'plugin2/autospeak.vim'
	execute 'source ' . g:vimspeech_root_dir . 'plugin2/audiomarks.vim'
	execute 'source ' . g:vimspeech_root_dir . 'plugin2/modules.vim'
	execute 'source ' . g:vimspeech_root_dir . 'plugin/tests.vim'
endif


