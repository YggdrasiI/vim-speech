" SECTION get_text
" Libary functions to fetch text/results for some operation
" without leaving of the command mode. Thus, this functions
" are available in <expr>-functions.
"
" The used regular expressions and some ideas was adapted from
" the plugin vim-easymotion, https://github.com/easymotion/vim-easymotion.git

let s:TRUE = !0
let s:FALSE = 0
let s:DIRECTION = { 'forward': 0, 'backward': 1, 'bidirection': 2}

" Transpose map from VIM motion into internal search pattern.
" The internal pattern should be more complex. Example:
" '[count]w' will be prefixed with a movement to the beginning of
" the current word.
let s:motion_mappings = {
      \ 'lw' : [
      \   ['w', 1],
      \   ['b', 1],
      \   ['start', [0, 0] ],
      \   ['w', 'count', 0],
      \   ['ge', 1],
      \   ['end', [0, 0]  ],
      \ ],
      \ 'w' : [
      \   ['start', [0, 0] ],
      \   ['w', 'count', 0],
      \   ['end', [0, 0]  ],
      \ ],
      \ 'b' : [
      \   ['start', [0, 0] ],
      \   ['b', 'count', 0],
      \   ['end', [0, 0]  ],
      \ ],
      \ }

" '[motion]' : ['[regex]', [direction], [offset_at_end_unused] ]
      " \ 'w' : ['\(\(\<\|\>\|\s\)\@<=\S\|^$\)', 0, 1],
      " \ 'b' : ['\(\(\<\|\>\|\s\)\@<=\S\|^$\)', 1, 0],
      " \(\%#.\k*\s*\|\n\s*\).', 'cWe')
      "\ 'w' : ['\k\+\s*.', 0, 'eW'],
let s:search_regex = {
      \ 'w' : ['\<\|^\S\|\s\zs\S\|\>\zs\S\|^$\|\%$', 0, 'eW'],
      \ 'b' : ['\<\|^\S\|\s\zs\S\|\>\zs\S\|^$\|\%$', 1, 'Wb'],
      \ 'e' : ['\(.\>\|^$\)', 0, 0],
      \ 'ge' : ['\(.\>\|^$\)', 1, 0],
      \ 'W' : ['\(\(^\|\s\)\@<=\S\|^$\)', 0, 0],
      \ 'B' : ['\(\(^\|\s\)\@<=\S\|^$\)', 1, 0],
      \ 'E' : ['\(\S\(\s\|$\)\|^$\)', 0, 0],
      \ 'gE' : ['\(\S\(\s\|$\)\|^$\)', 1, 0],
      \ }

" Config from vim-easymotion. Not all values used.
let s:config = {
      \   'pattern': '',
      \   'visualmode': s:FALSE,
      \   'direction': s:DIRECTION.forward,
      \   'inclusive': s:FALSE,
      \   'accept_cursor_pos': s:FALSE,
      \   'overwin': s:FALSE
      \ }

" FUNCTION Motion
" Return text for given motion like 'w'.
"
function! speech#get_text#Motion(motion, count)
endfunction


" FUNCTION Motion
" Return text for given text object like 'iw'.
"
function! speech#get_text#TextObject(motion)
endfunction


" FUNCTION BetweenPositions
" Return text between two text coordinates ([row, column])
"
function! speech#get_text#BetweenPositions(begin, end, bsort)
  if a:bsort > 0
    let [l:begin, l:end] = speech#get_text#SortPositions(a:begin, a:end)
  else
    let [l:begin, l:end] = [a:begin, a:end]
  endif
  let l:lines = getline(l:begin[0], l:end[0])
  " Shift end if it's on the $ position.
  "if l:end[1] > len(l:lines[-1])
  "  let l:end[1] -= 1
  "endif
  "echom l:lines[0]
  "echom l:begin[0] . ',' . l:begin[1] . '|' . l:end[0] . ',' . l:end[1]
  let l:lines[-1] = l:lines[-1][: l:end[1] - (&selection == 'inclusive' ? 1 : 2)]
  let l:lines[0] = l:lines[0][l:begin[1] - 1:]
  let l:selection_text = join(l:lines, "\n")
  return l:selection_text
endfunction

" FUNCTION SortPositions
function! speech#get_text#SortPositions(begin, end)
  if a:begin[0] > a:end[0] 
    return [a:end, a:begin]
  elseif a:begin[0] == a:end[0] &&
        \  a:begin[1] == a:end[1] 
    return [a:end, a:begin]
  else
    return [a:begin, a:end]
  endif
endfunction


function! speech#get_text#Bla(motion_list, count, visualmode)
  " Setup search
  call speech#get_text#Reset()

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
  for l:cur_motion in a:motion_list
    if l:cur_motion[0] ==# 'start'
      let l:offset = get(l:cur_motion, 1, [0,0])
      let s:current.begin_position = [line('.') + l:offset[0], col('.') + l:offset[1]]
      continue
    endif
    if l:cur_motion[0] ==# 'end'
      let l:offset = get(l:cur_motion, 1, [0,0])
      let s:current.end_position = [line('.') + l:offset[0], col('.') + l:offset[1]]
      continue
    endif

    let l:search = get(s:search_regex, l:cur_motion[0], 'undefined')
    let l:count = get(l:cur_motion, 1, 1)
    if l:count ==# 'count'
      let l:count = a:count
    endif
    let l:search_direction = (l:search[1] == 1 ? 'b' : '')
    let l:cursor_at_end = get(l:cur_motion, 2, 0)

    while l:count > 0
      let l:pos = searchpos(l:search[0],
            \ l:search_direction . (s:config.accept_cursor_pos ? 'c' : '')
            \ . (l:cursor_at_end ? 'e' : '') . 'W'
            \ , l:search_stopline)
      " Reached end of search range
      if l:pos == [0, 0]
        break
      endif
      let l:count -= 1
    endwhile
  endfor

  let s:current.end_position = get(s:current, 'end_position', [line('.'), col('.')])

  let l:result = speech#get_text#BetweenPositions(
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
    "keepjumps call cursor(s:current.cursor_position)
  endif

  return l:result
endfunction


function! speech#get_text#Reset()
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


function! speech#get_text#Word(count)
  let l:count1 = max([a:count, 1])
  let l:text = speech#get_text#Bla(
        \ get(s:motion_mappings,'w'), l:count1, 0)

  return speech#motion#ExprReturnValue(a:count)
  " Filtering text and speech
  let l:text = speech#filter#FilterLinebreaks(l:text)
  if len(l:text) == 1
    let l:text = speech#filter#FilterSingleCharacters(l:text, 1)
    call speech#Speak(l:text)
  else
    "echom "'" . l:text . "'"
    call speech#Speak(l:text)
  endif

  return speech#motion#ExprReturnValue(a:count)
endfunction

function! speech#get_text#Wordb(count)
  let l:count1 = max([a:count, 1])
  let l:text = speech#get_text#Bla(
        \ get(s:motion_mappings,'b'), l:count1, 0)

  return speech#motion#ExprReturnValue(a:count)
endfunction
