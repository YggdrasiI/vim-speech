
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
      let l:number_of_words_begin = get(l:settings, 'substring_words_begin', 2)
      let l:number_of_words_end = get(l:settings, 'substring_words_end', 2)

      if 0 ==  get(l:settings, 'substring_both_sides', 0)
        " Detect which side of selection is active and reduce spelled words
        " for the other side.
        let l:first_line = getpos(".")[1:2]
        let l:last_line = getpos("v")[1:2]
        if l:first_line[0] > l:last_line[0] 
          let l:number_of_words_begin = 0
        elseif l:first_line[0] == l:last_line[0] &&
              \  l:first_line[1] == l:last_line[1] 
          let number_of_words_begin = 0
        else
          let l:number_of_words_end = 0
        endif
      endif
      echom l:number_of_words_begin . ", " . l:number_of_words_end
      let l:subwords = []
      if 0 < l:number_of_words_begin
        let l:subwords += l:words[ 0 : l:number_of_words_begin - 1 ]
      endif
      if 0 < l:number_of_words_end
        let l:subwords += [' , ']
              \ + l:words[l:lenwords - l:number_of_words_end : l:lenwords - 1]
      endif
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
  let l:first_line = getpos(".")[1]
  let l:last_line = getpos("v")[1]
  if l:first_line > l:last_line
    let [l:first_line, l:last_line] = [l:last_line, l:first_line]
  endif

  call speech#Speak( printf(
        \ speech#locale#GetToken('selection_range'),
        \ l:first_line, l:last_line) )
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
