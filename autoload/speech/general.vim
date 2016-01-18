" SECTION General helper functions

" FUNCTION GetCurrentVisualSelection 
" Get current visual selection (during visual mode)
" or content of last visual selection (during other modes)
"
function! speech#general#GetCurrentVisualSelection()
  if -1 ==# index(['v','V',"\<C-V>"], mode(0))
    let l:posA = getpos("'<")[1:2]
    let l:posB = getpos("'>")[1:2]
  else
    let l:posA = getpos("v")[1:2]
    let l:posB = getpos(".")[1:2]
    if posA[0] > posB[0] || ( posA[0] == posB[0] && posA[1] > posB[1] )
      let [posA, posB] = [l:posB, l:posA]
    endif
  endif

  let l:selection_text = ''
  if 'v' == mode(0)
    let l:lines = getline(l:posA[0], l:posB[0])
    let l:lines[-1] = l:lines[-1][: l:posB[1] - (&selection == 'inclusive' ? 1 : 2)]
    let l:lines[0] = l:lines[0][l:posA[1] - 1:]
    let l:selection_text = join(l:lines, "\n")
    let l:selection_range =  [l:posA, l:posB]
  elseif 'V' == mode(0)
    let l:lines = getline(l:posA[0], l:posB[0])
    "let l:number_of_lines = l:posB[0]-l:posA[0]+1
    "return ( l:number_of_lines . ( l:number_of_lines==1? ' Zeile. ' : ' Zeilen. ') )
    let l:selection_text = join(l:lines, "\n")
    let l:selection_range =  [[l:posA[0], 0], [l:posB, len(l:lines[-1])] ]
  elseif "\<C-V>" == mode(0)
    let lines = getline(l:posA[0], l:posB[0])
    let [l:col_left, l:col_right] = [l:posA[1]-1, l:posB[1]-1]
    if l:posA[1] > l:posB[1]
      let [l:col_left, l:col_right] = [l:posB[1]-1, l:posA[1]-1]
    endif
    let l:blocks = []
    for l in lines
      " The following block selection does not respect the problems due the
      " usage of tabulators. TODO: Respect width of tabs to determine
      " blockwidth for each line. 
      let l:blocks += [ l[ l:col_left : l:col_right ] ]
    endfor
    let l:selection_text = join(l:blocks, "\n")
    let l:selection_range =  [[l:posA[0], l:col_left], [l:posB, l:col_right]]
  endif
  return ([l:selection_text, l:selection_range])
endfunction


" FUNCTION GetCurrentCharacter
" Returns character under the cursor.
"
function! speech#general#GetCurrentCharacter()
  let l:pos = getpos(".")
  let l:line = getline(l:pos[1])

  if has("multi_byte_encoding") == 0
    " Note: This simple approach fails for unicode characters with multiple bytes.
    return l:line[l:pos[2]-1]
  endif

  let l:char_pos1 = l:pos[2] - 1
  let l:char1 = l:line[l:char_pos1]
  " Types (see UTF-8 documentation):
  " 00xxxxxx (0, ascii),
  " 11xxxxxx (3 utf-8 head),
  " 10xxxxxx (2, utf-8 tail)
  let l:char_type = char2nr(l:char1)/64
  while( l:char_type == 2 && l:pos1 > 0)
    let l:char_pos1 = l:char_pos1 - 1
    let l:char1 = l:line[l:char_pos1]
    let l:char_type = char2nr(l:char1)/64
  endwhile 

  if l:char_type == 3
    " Extract length information out of the utf-8 head character 
    " and substract one.
    let l:char_number_of_bytes = max([0, char2nr(l:char1)/16 % 4 - 1 ]) + 1 
    return l:line[l:char_pos1 : l:char_pos1 + l:char_number_of_bytes]
  else
    return l:char1
  endif

endfunction


" FUNCTION PingMode
" Generate audio feedback for current VIM mode.
"
function! speech#general#PingMode(mode)
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
  call speech#sound#Play(l:filename)
endfunction


" FUNCTION CheckMode
" Check if current mode differs from previous and
" give accoustic feedback for changes.
" If the input argument is empty it will automatically detect the current
" mode.
"
let g:vs_last_mode = ''
let g:vs_last_buffer = -1
function! speech#general#CheckMode(mode)
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
    return ''
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
      call speech#Speak( l:mode_text )
    endif

  elseif g:vs_last_mode !=# l:cur_mode
    "let l:mode_text .= 'Mode ' . l:cur_mode . '. '
    call speech#general#PingMode(l:cur_mode)

  else
    "Check :messages buffer
    if l:cur_mode == 'n'
      redir END
      if g:messbuf != ''
        let mess = split(g:messbuf,"\n")
        if len(l:mess) > 1
          "call speech#Speak( l:mess[0] )
          call speech#Speak( 'Ende eines Befehls' )
          "echon 'Nachricht:' . l:mess[0] . 'END'
        endif
      endif
      redir => g:messbuf
    endif
  endif

  let g:vs_last_mode = l:cur_mode
  let g:vs_last_buffer = l:cur_buffer
  return ''
endfunction

