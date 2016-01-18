" SECTION Definition of speech engine calls.
" Every text which should be spoken will call the function speech#Speak.
" This function uses the global variable g:speech#engine to select one
" of the given engines.
" Call TODO ListEngines() to get a list of available engines.

""
" FUNCTION ListEngines
" 
function! speech#ListEngines() 
  let engines = 'espeak, pico, '
  let text = printf( speech#locale#GetToken('available_speech_engines'), l:engines )
  call speech#Espeak(l:text)
endfunction


"" FUNCTION Speak
" Push text to currently selected speech engine over a system call.
" The following functions of this section defines the available targets 
" of this function. Currently, only Espeak is supported. 
"
function! speech#Speak(text) 
  if g:speech#silent
    return
  endif
  if g:speech#engine ==? 'espeak'
    call speech#Espeak(a:text)
  elseif g:speech#engine ==? 'pico'
    call speech#Picospeech(a:text)
  endif
endfunction


"" FUNCTION Espeak
" Kill running instances of espeak and create new one.
"
function! speech#Espeak(text) 
  " First approach Use text as argument. Quote characters made trouble.
  let l:text = escape(a:text, '"\')
  call system('killall espeak ; espeak -v'.g:speech#language . ' ' . g:speech#espeak_options . '  "' . l:text . '" 1&> /dev/null &')
  
  " Second approach. Send text over stdin
  "call system('killall espeak')
  "call system('espeak -v'.g:speech#language . ' '
  "      \ . g:speech#espeak_options .'1&> /dev/null &',
  "      \ a:text . '" ')
  
  " Debugging
  "redraw!
  "echom '(Espeak) ' . a:text
  "echom tr(a:text,"\n",' ')[0:30]
endfunction


"" FUNCTION Picospeech
" Like Espeak function but for picospeech enigne.
" Note that picospeech ignore double quotes characters during speech. This
" made it difficult to detect comment lines in vim script files...
"
function! speech#Picospeech(text) 
  " This variant uses an argument for the text. It requires escaping of
  " double quote.
  let l:text = escape(a:text, '"')
  call system(" killall aplay ; killall testtts ;" .
        \ g:speech#root_dir . "bash/picospeech -l " . g:speech#language . " \"" . l:text . "\" &")

  " This variant uses stdin for the text. Character escaping not required.
  "call system('killall aplay ; killall testtts ;')
  "call system(g:speech#root_dir . "bash/picospeech -l '" . g:speech#language . "' &", a:text)

  " Debugging
  "echom '(Pico) ' . a:text
endfunction


" SECTION Unnamed section
"" FUNCTION Range
" Get information about a VIM range.
"
function! speech#Range() range
  if a:firstline == a:lastline
    let msg = speech#locale#GetToken('line') . a:firstline 
  else
    let msg = printf( speech#locale#GetToken('selection_line_range'), a:firstline, a:lastline )
  endif
  call speech#Speak(l:msg)
endfunction


"" FUNCTION Linenumber
" Get line number of cursor.
"
function! speech#Linenumber()
  call speech#Speak( line(".") )
endfunction


"" FUNCTION Position
" Get position of cursor
"
function! speech#Position()
  let curpos = getpos(".")
  let msg = speech#locale#GetToken('line') . l:curpos[1] .
        \ speech#locale#GetToken('character') . l:curpos[2]
  silent! call speech#Speak ( l:msg )
endfunction


"" FUNCTION Filename
" Speech of filename.
"
function! speech#Filename()
  let msg = printf( speech#locale#GetToken('filename'), expand("%:t") )
  call speech#Speak(l:msg)
endfunction


"" FUNCTION Line
" Speech next N lines.
"
function! speech#Line(count1) 
  let curpos = getpos(".")
  let l:msg = join(getline(l:curpos[1] , l:curpos[1] + a:count1 - 1),' ')
  let l:msg = speech#filter#FilterLinebreaks(l:msg)

  let l:msg = speech#filter#FilterSingleCharacters(l:msg, 0)

  call speech#Speak(l:msg)
  return ''
endfunction


"" FUNCTION Word
" Speech next n words (n movements with lowercase w motion).
"
function! speech#Word(count) 
  call speech#Motion(a:count, "w", "b")
endfunction


"" FUNCTION WORD
" Speech next n WORDS (n movements with uppercase w motion).
"
function! speech#WORD(count) 
  call speech#Motion(a:count, "W", "b")
  "let wordUnderCursor = expand("<cWORD>")
endfunction


"" FUNCTION Char
" Speech next n characters under the cursor.
"
function! speech#Char(count) 
  let curpos = getpos(".")
  execute 'normal! "sy'. max([1,a:count]) . 'k'
  let text = speech#filter#FilterSingleCharacters(@s, 1)
  call speech#Speak( Sfilter_linebreaks(l:text) )
  call setpos (".", l:curpos )
endfunction


"" FUNCTION PreserveCursor
" Wrap function call to
" save current cursor position (cursor move to line start on buffer switch)
" and omit sound during handling
" Note: The following approach should working, too. 
" let l:curpos = getpos("`s")
"  [cursor movements]
"  call setpos ("'s", l:curpos )
" Note: The following approach does not work for all yanking movements:
" let l:curpos = getpos(".")
"  [cursor movements]
"  call setpos (".", l:curpos )
"
function! speech#PreserveCursor(handler)
  let l:view = winsaveview()
  let g:speech#silent = 1

  execute a:handler

  let g:speech#silent = 0
  call winrestview(l:view)
endfunction


"" FUNCTION PreserveCursorVisual
" Wrapper for visual mode
"
function! speech#PreserveCursorVisual(handler, movement)
  let g:speech#silent = 1
  execute a:handler
  let g:speech#silent = 0
  return a:movement
endfunction


"" FUNCTION Movement
" Speech text between current cursor position and the position after
" the given movement.
"
function! speech#Movement(movement, count, filter)
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

  let l:msg = speech#filter#FilterLinebreaks(l:msg)

  if speech#utf#IsSingleCharacter(l:msg) == 1
    let l:msg = speech#filter#FilterSingleCharacters(l:msg, 1)
  else
    " Just for testing. Should be optional
    let l:msg = speech#filter#FilterSingleCharacters(l:msg, 0)
  endif

  let msg = speech#filter#FilterQuotes(l:msg, 0)

  let g:speech#silent = 0
  call speech#Speak(l:msg)
  let @" = l:backup
  return ''
endfunction


"" FUNCTION Vmovement
" Same functionality as movement, but visual mode 
" require other approach.
"
function! speech#Vmovement(movement, count, filter)
  let msg = @*  
  if len(l:msg) == 1
    let msg = speech#filter#FilterSingleCharacters(l:msg)
  endif
  if a:filter != ''
    execute 'call ' . a:filter . '(l:msg)'
  endif
  let g:speech#silent = 0
  call speech#Speak(l:msg)
  "silent! 'normal! gv'
  "return ''
endfunction


"" FUNCTION Vmovement2
"
function! speech#Vmovement2(movement, count, filter)
  if len(@*) == 1
    let @s = speech#filter#FilterSingleCharacters(@*, 1)
  endif
  if a:filter != ''
    execute 'call ' . filter . '(@*)'
  endif
  let g:speech#silent = 0
  call speech#Speak(@s)
  "silent! 'normal! gv'
  "return ''
endfunction


"" FUNCTION Motion
" Fetch text for a motion. Arguments:
" count: number of motions
" motion: type of motion, in example 'w'.
" premove: motion before text will be evaluated. Used to move to begin of
" word.
"
function! speech#Motion(count, motion, premove) 
  let curpos = getpos(".")
  let nbr = max([1,a:count])

  " Optional move to begin of word
  if a:premove ==# "b"
    call feedkeys('wb', 'n') " ignore remapping of w,b
  endif

  execute 'norm! "sy' . l:nbr . a:motion
  call setpos (".", l:curpos )

  let msg = speech#filter#FilterLinebreaks(@s)
  if len(l:msg) == 1
    let msg = speech#filter#FilterSingleCharacters(@s, 1)
    call speech#Speak(l:msg )
  else
    echo l:msg
    call speech#Speak(l:msg)
  endif
endfunction


"" FUNCTION DetectVisualMode
" Deprecated / Old / Veraltet
"
function! speech#DetectVisualMode()
    let m = visualmode()
    if m ==# 'v'
        call speech#Speak('character-wise visual mode')
    elseif m ==# 'V'
        call speech#Speak('line-wise visual mode')
    elseif m ==# "\<C-V>"
        call speech#Speak('block-wise visual mode')
    endif
    " Restore visual mode
    normal! gv
endfunction


"" FUNCTION CmdTest
"
function! speech#CmdTest(text)
  let cmd = getcmdline()
  let msg = speech#filter#FilterLinebreaks(a:text)
  call speech#Speak(l:msg)
  "<C-\>eescape(getcmdline(), ' \')<CR>
 return l:cmd
endfunction


"" FUNCTION GetMode
" Map mode keyword on effable text.
function! speech#GetMode(mode)
  if a:mode[0] ==# 'i'
    let mode_text = 'Insert Mode'
  elseif a:mode[0] ==# 'c'
    let mode_text = 'Command Mode'
  elseif a:mode[0] ==# 'v'
    let mode_text = 'Visual Mode'
  elseif a:mode[0] ==# 'V'
    let mode_text = 'Visual Line Mode'
  elseif a:mode[0] ==# "\<C-V>"
    let mode_text = 'Visual Block Mode'
  elseif a:mode[0] ==# 'n'
    let mode_text = 'Normal Mode'
  else
    let mode_text = 'Unknown Mode'
  endif

  "extra check to distict normal mode 
  "in command line buffer from other buffers
  if bufname("") ==# '[Command Line]'
    call speech#Speak( l:mode_text . ' in Command Line')
  else
    call speech#Speak( l:mode_text )
  endif

return ''
endfunction


