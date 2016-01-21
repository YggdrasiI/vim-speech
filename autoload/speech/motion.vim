" SECTION Constants
" This regex marks all keyword beginnings.
" Note: '\<' is not enough! It does not stop on '\S' characters.
let s:keyword_beginnings = '\<\|^\S\|\s\zs\S\|\>\zs\S'


" SECTION Functions for word-wise movement.

" FUNCTION NextWordButNoEmptyLines
" Like w, but does not stop on empty lines.
" Not used.
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


" FUNCTION Motion_b
"
function! speech#motion#Motion_b(count1)
  let l:next = [[0,0]] + speech#motion#Jumpmarks_b(getpos("."), a:count1)
  call cursor(l:next[-1])
endfunction

" FUNCTION Motion_w
"
function! speech#motion#Motion_w(count1)
  " Create list with at least one element
  let l:next = [[0,0]] + speech#motion#Jumpmarks_w(getpos("."), a:count1)
  call cursor(l:next[-1])
endfunction


" SECTION Collect jumpmarks for movements
" FUNCTION Jumpmarks_w
"
function! speech#motion#Jumpmarks_w(start_position, count1)
  let l:return_positions = []
  let l:count = a:count1
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

" SECTION Test functions for this script.
function! speech#motion#RunTests()
  call s:speech#motion#Test_CompareMovements(
        \ 's:speech#motion#HandleNormalW()',
        \ 'speech#motion#NextWord(1)',
        \ 0)
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
function! s:speech#motion#Test_CompareMovements(movement_handler1, movement_handler2, backward)
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
      execute 'call ' . l:h . '()'
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
  endif

  return -1
endfunction


" FUNCTION HandleNormalW
" Wraps 'w' movement for test function.
"
function! s:speech#motion#HandleNormalW()
  silent execute ':normal! w'
endfunction

