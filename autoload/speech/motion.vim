" SECTION Constants
"
let s:TRUE = !0
let s:FALSE = 0
let s:DIRECTION = { 'forward': 0, 'backward': 1, 'bidirection': 2}

" Config from vim-easymotion. Not all values used.
let s:config = {
      \   'pattern': '',
      \   'visualmode': s:FALSE,
      \   'direction': s:DIRECTION.forward,
      \   'inclusive': s:FALSE,
      \   'accept_cursor_pos': s:FALSE,
      \   'overwin': s:FALSE
      \ }

" Transpose map from VIM motion into internal search pattern.
" This regex marks all keyword beginnings.
" Note: '\<' is not enough! It does not stop on '\S' characters.
let s:keyword_beginnings = '\<\|^\S\|\s\zs\S\|\>\zs\S'

let s:keyword_beginnings2 = '\<\|^\S\|\s\zs\S\|\>\zs\S\|^$\|\%$'

" w: Next word beginning
" b: Previous word beginning
" e: Next word end. Note that VIM's 'e' not stop on empty lines. 
" ge: Previous word end.
" bc: Beginning of current word. (Stable on word beginning.)
" ec: End of current word. (Stable on word end.)
let s:search_variants = {
      \ 'w' : {'regex': '\<\|^\S\|\s\zs\S\|\>\zs\S\|^$\|\%$',
      \        'handler' : 'search', 'flags': 'eW'},
      \ 'b' : {'regex': '\<\|^\S\|\s\zs\S\|\>\zs\S\|^$\|\%$',
      \        'handler' : 'search', 'flags': 'bW'},
      \ 'wc' : {'regex': '\<\|^\S\|\s\zs\S\|\>\zs\S\|^$\|\%$',
      \        'handler' : 'search', 'flags': 'cW'},
      \ 'bc' : {'regex': '\<\|^\S\|\s\zs\S\|\>\zs\S\|^$\|\%$',
      \        'handler' : 'search', 'flags': 'bcW'},
      \ 'e' : {'regex': '\(.\ze\>\|\S\ze\s*$\|\S\ze\s\|\k\zs\>\S\ze\|\S\<\)',
      \        'handler' : 'search', 'flags': 'eW'},
      \ 'null' : {'regex': '\%#',
      \        'handler' : 'search', 'flags': 'cW'},
      \ }
      "\ 'bc' : {'regex': '\<\k*\|\s\zs\S\+\|\S\<',

let s:motion_sequences = {
      \ 'next_words' : [ {'start': 1},
      \             {'motion1': 'w', 'motion2': 'null', 'cycles': 'count'},
      \             {'end' : 1},
      \           ],
      \ 'previous_words' : [ {'start': 1},
      \             {'motion1': 'b', 'cycles': 'count'},
      \             {'end' : 1},
      \           ],
      \ 'this_and_next_words' : [ 
      \             {'motion1': 'bc'},
      \             {'start': 1},
      \             {'motion1': 'w', 'motion2': 'ec'},
      \             {'end' : 1},
      \           ],
      \ 'test' : [ 
      \             {'start': 1},
      \             {'motion1': 'e'},
      \             {'end' : 1},
      \           ],
      \ }

      "\ 'lw' : [
      "\   ['w', 1],
      "\   ['b', 1],
      "\   ['start', [0, 0] ],
      "\   ['w', 'count', 0],
      "\   ['ge', 1],
      "\   ['end', [0, 0]  ],
      "\ ],
      "

" FUNCTION HandleVariant
" Operates on entries of s:search_variants.
"
function! speech#motion#HandleVariant(variant)
  if get(a:variant, 'handler'. '') ==# 'search'
    call searchpos(
          \ get(a:variant, 'regex'),
          \ get(a:variant, 'flags')
          \ )
  endif
endfunction

function! speech#motion#GetPositions(sequence_key, count, visualmode)
  " Setup search
  call speech#motion#Reset()

  let l:sequence = get(s:motion_sequences, a:sequence_key)

  let s:current.cursor_position = [line('.'), col('.')]
  let win_first_line = line('w0') " visible first line num
  let win_last_line  = line('w$') " visible last line num

  let search_stopline = 0
  if ! empty(a:visualmode)
    let search_stopline = a:direction == 1 ? win_first_line : win_last_line
  endif
  if s:flag.within_line == 1
    let search_stopline = s:current.original_position[0]
  endif


  " Do the search
  let s:current.begin_position = s:current.cursor_position
  let l:positions = []
  let l:record = 0

  for l:cur_step in l:sequence 
    if get(l:cur_step, 'start', 0)
      let l:record = 1
      continue
    endif
    if get(l:cur_step, 'end', 0)
      let l:record = 0
      continue
    endif

    let l:cycles = get(l:cur_step, 'cycles', 1)
    if l:cycles ==# 'count'
      let l:cycles = a:count
    endif

    while 0 < l:cycles
      let l:motion1 = get(s:search_variants,
            \ get(l:cur_step, 'motion1') )
      if !empty(l:motion1)
        call speech#motion#HandleVariant(l:motion1)
        let l:cur_position1 = [line('.'), col('.')]
      else
        echom '(GetPositions) Motion 1 not defined.'
        let l:cur_position1 = [-1, -1]
      endif

      let l:motion2 = get(s:search_variants,
            \ get(l:cur_step, 'motion2') )
      if !empty(l:motion2)
        call speech#motion#HandleVariant(l:motion2)
        let l:cur_positions = [l:cur_position1, [line('.'), col('.')]] 
      else
        let l:cur_positions = [l:cur_position1] 
      endif

      if l:record
        let l:positions += [ l:cur_positions ] 
      endif

      let l:cycles -= 1
    endwhile

  endfor

  let s:current.end_position = get(s:current, 'end_position', [line('.'), col('.')])

  let l:tmp = speech#get_text#BetweenPositions(
        \ s:current.begin_position,
        \ s:current.end_position,
        \ 1)

  " Cleanup
  " -- Jump back before prompt for visual scroll
  " Because searchpos() change current cursor position and
  " if you just use cursor(s:current.cursor_position) to jump back,
  " current line will become middle of line window
  if ! empty(a:visualmode)
    keepjumps call winrestview({'lnum' : s:current.cursor_position[0], 'topline' : win_first_line})
  else
    " for adjusting cursorline
    keepjumps call cursor(s:current.cursor_position)
  endif

  " Debugging
  "echom string(l:positions)
  "echom l:tmp
  "echom string(l:positions[-1])
  "keepjumps call cursor(l:positions[-1][-1])
  
  return l:positions
endfunction



" SECTION Functions for word-wise movement.

" FUNCTION NextWordButNoEmptyLines
" Like w, but does not stop on empty lines.
" Not used.
" Error: Does not hold on ! in '^! keyword'.
"
function! speech#motion#NextWordButNoEmptyLines()
  let l:curpos = getpos('.')
  let l:text = getline(l:curpos[1])[l:curpos[2] - 1]

  if -1 < match(l:text, '\k')
    let pos = searchpos('\%#\k\(\k*\s*\(\n\s*\)*.\)', 'cWe')
    "echo 'a) ' . l:pos[0] . ',' . pos[1]
  else
    let pos = searchpos('\(\k\|\s\+\S\)', 'We')
    "echo 'b) ' .l:pos[0] . ',' . l:pos[1]
  endif
endfunction


" FUNCTION Motion_w
"
function! speech#motion#Motion_w(count)
  " Create list with at least one element
  let l:next = [[0,0]] +
        \ speech#motion#Jumpmarks_w(
        \   getpos("."), max([1, a:count]) )
  call cursor(l:next[-1])
  return speech#motion#ExprReturnValue(a:count)
endfunction


" FUNCTION Motion_b
"
function! speech#motion#Motion_b(count)
  let l:count1 = max([1, a:count])
  while 0 < l:count1
    call speech#motion#HandleVariant(
          \ get(s:search_variants, 'b', 'null'))
    let l:count1 -= 1
  endwhile
  return speech#motion#ExprReturnValue(a:count)
endfunction

" FUNCTION Motion_e
"
function! speech#motion#Motion_e(count)
  let l:count1 = max([1, a:count])
  while 0 < l:count1
  while 0 < l:count1
    call speech#motion#HandleVariant(
          \ get(s:search_variants, 'e', 'null'))
    let l:count1 -= 1
  endwhile
  return speech#motion#ExprReturnValue(a:count)
endfunction

" FUNCTION ExprReturnValue
" Return string <Del> characters
" One for each numeral of a:count.
"
function! speech#motion#ExprReturnValue(count)
  let l:count = a:count
  let l:del_char_string = ''
  while l:count > 0
    let l:del_char_string .= "\<Del>"
    let l:count = l:count / 10
  endwhile
  return l:del_char_string
endfunction


" SECTION Collect jumpmarks for movements
"
" FUNCTION Jumpmarks_w
" Simulate a:count movements by 'w' and return list
" of cursor positions after each movement.
" 
function! speech#motion#Jumpmarks_w(start_position, count)
  let l:return_positions = []
  let l:count = a:count
  let l:current_line = a:start_position[1]
  let l:current_char = a:start_position[2] - 1

  let l:text = getline(l:current_line)
  while l:count > 0
    if -1 < match(l:text[l:current_char], '\s')
      let l:col = match(l:text[l:current_char :], s:keyword_beginnings, 0, 1)
    else
      " First match reserved for current position. Use second match.
      let l:col = match(l:text[l:current_char :], s:keyword_beginnings, 0, 2)
    endif
    " Attention: Using the start-argument to right shift the search.
    " Does not return the same results for all inputs!
    " Example:  ' ! Text' Calling the functions with the line below
    "             ^
    " does not jump to 'T'.
    "let l:col = match(l:text, s:keyword_beginnings, l:current_char, 2)

    if -1 < l:col
      let l:count -= 1
      let l:current_char = l:current_char + l:col 
      "let l:current_char = l:col  "Above errorous approach without offset.
      
      let l:return_positions += [[l:current_line, l:current_char + 1]]
    else
      " Go to next line
      let l:current_line += 1 
      let l:current_char = 0 
      let l:text = getline(l:current_line)
      " Empty lines consume movement
      if '' ==# l:text 
        if l:current_line > line("$")
          " Add last char position once only.
          let l:return_positions += [[line('$'), len(getline('$'))]]
          return l:return_positions 
        endif
        let l:count -= 1
        let l:return_positions += [[l:current_line, 1]]
      else
        " Find first matching occurence. The above match() would skip them.
        let l:col = match(l:text, s:keyword_beginnings, l:current_char, 1)
        let l:current_char = l:col 
        if -1 < l:col
          let l:count -= 1
          let l:return_positions += [[l:current_line, l:current_char + 1]]
        endif
      endif
    endif
  endwhile
  return l:return_positions
endfunction

" FUNCTION Jumpmarks_b
" Go backwarts by 'b' and store a:count positions.
"
function! speech#motion#Jumpmarks_b(start_position, count)
endfunction


" SECTION Test functions for this script.
function! speech#motion#RunTests()
        "\ 'speech#motion#NextWordButNoEmptyLines()',
        "\ 'speech#motion#Motion_w(1)',
        "\ 'speech#get_text#Word(1)',
  if 0 == speech#motion#Test_CompareMovements(
        \ 'speech#motion#HandleNormalW()',
        \ 'speech#motion#Motion_w(1)',
        \ 0)
    echom "(RunTests) Test_CompareMovements for 'w' passed."
  endif
  if 0 == speech#motion#Test_CompareMovements(
        \ 'speech#motion#HandleNormalB()',
        \ 'speech#motion#Motion_b(1)',
        \ 1)
    echom "(RunTests) Test_CompareMovements for 'b' passed."
  endif
  if 0 == speech#motion#Test_CompareMovements(
        \ 'speech#motion#HandleNormalE()',
        \ 'speech#motion#Motion_e(1)',
        \ 0)
    echom "(RunTests) Test_CompareMovements for 'e' passed."
  endif
endfunction


" FUNCTION Test_CompareMovements
" Compare two cursor movement styles on current buffer.
" It will loop through a file and collect the positions 
" where the cursor stops.
" If it detects a differenc between the movements,
" the function jumps to the previous (still matching) position
" and return -1.
" Otherwise 0 will be returned.
"
function! speech#motion#Test_CompareMovements(movement_handler1, movement_handler2, backward)
  let l:xxx = [
        \ [a:movement_handler1, []],
        \ [a:movement_handler2, []],
        \ ]

  " Loop through current buffer
  for [l:h, l:list] in l:xxx
    if a:backward == 1
      call cursor(getpos('$')[1:2])
    else
      call cursor([1,1])
    endif

    let l:lastpos = [0,0]
    execute 'call ' . l:h
    let l:curpos = getpos(".")[1:2]

    while l:lastpos != l:curpos 
      let l:list += [l:curpos]
      let l:lastpos = l:curpos
      execute 'call ' . l:h
      let l:curpos = getpos(".")[1:2]
    endwhile
  endfor

  " Now, the resulting lists are stored in l:xxx[*][1]
  let [l:a, l:b] = [ l:xxx[0][1], l:xxx[1][1] ]

  if l:a == l:b
    return 0
  endif

  " Debugging output
   echom '(TestCompareMovements) Length of both lists: ' . len(l:a) . ',' . len(l:b) 
  " echom string(l:a)
  " echom string(l:b)

  " List differs. Find last entry with same position.
  let l:index = 0
  let l:len = min([len(l:a), len(l:b)]) 
  while l:index < l:len
    if l:a[l:index] != l:b[l:index]
      break
    endif
    let l:index += 1
  endwhile
  if l:index > 0
    echom '(TestCompareMovements) Error found after entry '
          \ . (l:index-1) . ': '
          \ . string(l:a[l:index-1])
    call cursor(l:a[l:index-1])
    if l:index < l:len
      echom string(l:a[l:index]) . ' vs '
          \ . string(l:b[l:index])
    endif
  endif

  return -1
endfunction


" FUNCTION HandleNormalW
" Wraps 'w' movement for test function.
"
function! speech#motion#HandleNormalW()
  silent execute ':normal! w'
endfunction
" FUNCTION HandleNormalW
function! speech#motion#HandleNormalB()
  silent execute ':normal! b'
endfunction
" FUNCTION HandleNormalE
function! speech#motion#HandleNormalE()
  silent execute ':normal! e'
endfunction



function! speech#motion#Reset()
  let s:flag = {
        \ 'within_line' : 0,
        \ 'dot_repeat' : 0,
        \ 'regexp' : 0,
        \ 'bd_t' : 0,
        \ 'find_bd' : 0,
        \ 'linewise' : 0,
        \ 'count_dot_repeat' : 0,
        \ }
  " regexp: -> regular expression
  "   This value is used when multi input find motion. If this values is
  "   1, input text is treated as regexp.(Default: escaped)
  " bd_t: -> bi-directional 't' motion
  "   This value is used to re-define regexp only for bi-directional 't'
  "   motion
  " find_bd: -> bi-directional find motion
  "   This value is used to recheck the motion is inclusive or exclusive
  "   because 'f' & 't' forward find motion is inclusive, but 'F' & 'T'
  "   backward find motion is exclusive
  " count_dot_repeat: -> dot repeat with count
  "   https://github.com/easymotion/vim-easymotion/issues/164

  let s:current = {
        \ 'is_operator' : 0,
        \ 'is_search' : 0,
        \ 'dot_repeat_target_cnt' : 0,
        \ 'dot_prompt_user_cnt' : 0,
        \ 'changedtick' : 0,
        \ }
  " \ 'start_position' : [],
  " \ 'cursor_position' : [],

  " is_operator:
  "   Store is_operator value first because mode(1) value will be
  "   changed by some operation.
  " dot_* :
  "   These values are used when '.' repeat for automatically
  "   select marker/label characters.(Using count avoid recursive
  "   prompt)
  " changedtick:
  "   :h b:changedtick
  "   This value is used to avoid side effect of overwriting buffer text
  "   which will change b:changedtick value. To overwrite g:repeat_tick
  "   value(defined tpope/vim-repeat), I can avoid this side effect of
  "   conflicting with tpope/vim-repeat
  " start_position:
  "   Original, start cursor position.
  " cursor_position:
  "   Usually, this values is same with start_position, but in
  "   visualmode and 'n' key motion, this value could be different.
  return ''
endfunction
