
" FUNCTION SpeakVisualSelection
" 
function! speech#visual_mode#SpeakVisualSelection()
  "let msg = @*
  let msg = speech#general#GetCurrentVisualSelection()[0]
  call speech#Speak( tr(l:msg, "\n\r", '  ') )
  return ''
endfunction


" FUNCTION VisualSelectionSpell
" TODO Renaming
" Spell current/last selection.
" For long selection only the beginning and end will be spelled out.
" Use the dict argument spell_limits to define when only a substring should 
" be spelled out.
"
function! speech#visual_mode#VisualSelectionSpell(settings, save_settings) 

  " Merge manual given settings with default values
  let l:settings = copy(g:vs_visual_selection_settings_last)
  call extend(l:settings, a:settings)
  " Optional, save new settings
  if a:save_settings == 1
    let g:vs_visual_selection_settings_last = l:settings
  endif

  " The @* register just exists in X11 environments
  "let selected_text = @*
  let selected_text = speech#general#GetCurrentVisualSelection()[0]
  " Todo: Select substring if text is to long. Otherwise, everything runs very
  " slow.
  let selected_text = substitute(l:selected_text, '\n', ' ', 'g')

  if len(l:selected_text) > 0 
    "let words = split(l:selected_text,'\W\+')
    let words = split(l:selected_text,'\s\+')
    let lenwords = len(l:words)
    if l:lenwords < get(l:settings, 'max_number_of_words', 5)
      " Spell whole selection
      call speech#Speak(l:selected_text)
    else
      " Reduce spelling on head and tail of selection
      let l:subwords = l:words[ 0:get(l:settings, 'substring_words_start', 2) - 1 ]
            \+[' , ']
            \+l:words[ l:lenwords-get(l:settings, 'substring_words_end', 2): ]
      call speech#Speak( join(l:subwords) )
    endif
  endif

  return ''
endfunction


" FUNCTION VisualSelectionSwapSelectedEnd1
" Save cursor position before the position changes.
"
function! speech#visual_mode#VisualSelectionSwapSelectedEnd1() 
  let g:visual_selection_prev_cursor_position = getpos(".")
  return ''
endfunction


" FUNCTION VisualSelectionSwapSelectedEnd2
" Compare cursor position with previous value.
"
function! speech#visual_mode#VisualSelectionSwapSelectedEnd2() 

  let curpos = getpos(".")
  let lastpos = g:visual_selection_prev_cursor_position
  " Note: The following positions are the wrong and from the previous selection
  "let selection_start = getpos("'<")
  "let selection_end = getpos("'>")

  if l:lastpos == l:curpos 
    "call speech#Speak( 'Visual block contains just one character. ' )
    call speech#Speak( speech#locale#GetToken('selection_single_character')  )
  elseif l:curpos[1] < l:lastpos[1] || ( l:curpos[1] == l:lastpos[1] && l:curpos[2] < l:lastpos[2] )
    "call speech#Speak( 'Start of visual block selected. ' )
    call speech#Speak( speech#locale#GetToken('selection_cursor_at_start') )
  elseif l:curpos[1] > l:lastpos[1] || ( l:curpos[1] == l:lastpos[1] && l:curpos[2] > l:lastpos[2] )
    call speech#Speak( speech#locale#GetToken('selection_cursor_at_end') )
  endif

  return ''
endfunction


" FUNCTION VisualSelectionLineNumbers
" Spell linenumber of cursor.
"
function! speech#visual_mode#VisualSelectionLineNumbers() 
  let curpos = getpos(".")
  let curpos2 = getpos("v")
  call speech#Speak( curpos[1] . ' to ' . curpos2[1] )
  return ''
endfunction


" FUNCTION VisualSelectionSpellChar
" Spell character under cursor.
"
function! speech#visual_mode#VisualSelectionSpellChar() 
  let l:msg = speech#general#GetCurrentCharacter()
  call speech#Speak( l:msg )
  return ''
endfunction
