" SECTION Autospeak
" MAPPING word motions 
nnoremap <silent> w w:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
nnoremap <silent> b b:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
nnoremap <silent> W W:<C-U>call speech#PreserveCursor('call speech#Movement("yiW",0,"")')<CR>
nnoremap <silent> B B:<C-U>call speech#PreserveCursor('call speech#Movement("yiW",0,"")')<CR>
"nnoremap <silent> e e:<C-U>call speech#PreserveCursor('call speech#Movement("yl",0,"")')<CR>
"nnoremap <silent> E E:<C-U>call speech#PreserveCursor('call speech#Movement("yl",0,"")')<CR>
nnoremap <silent> e e:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
nnoremap <silent> E E:<C-U>call speech#PreserveCursor('call speech#Movement("yiW",0,"")')<CR>
nnoremap <silent> ge ge:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
nnoremap <silent> gE gE:<C-U>call speech#PreserveCursor('call speech#Movement("yiW",0,"")')<CR>

" MAPPING Charwise movements (VIM arrow style).
if g:speech#keyboard_layout ==? "neo"
  nnoremap <silent> s h:<C-U>call speech#PreserveCursor('call speech#Movement("yl",0,"")')<CR>
  nnoremap <silent> t l:<C-U>call speech#PreserveCursor('call speech#Movement("yl",0,"")')<CR>
  nnoremap <silent> n j:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
  nnoremap <silent> r k:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
else
  nnoremap <silent> h h:<C-U>call speech#PreserveCursor('call speech#Movement("yl",0,"")')<CR>
  nnoremap <silent> l l:<C-U>call speech#PreserveCursor('call speech#Movement("yl",0,"")')<CR>
  nnoremap <silent> j j:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
  nnoremap <silent> k k:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
endif


" MAPPING object motions 
"nnoremap <silent> ( (:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
"nnoremap <silent> ) ):<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
execute 'nnoremap <silent> ( (:<C-U>call speech#Speak("'
      \ . speech#locale#GetToken('previous_sentence') . '")<CR>'
execute 'nnoremap <silent> ) ):<C-U>call speech#Speak("'
      \ . speech#locale#GetToken('next_sentence') . '")<CR>'
execute 'nnoremap <silent> { {:<C-U>call speech#Speak("'
      \ . speech#locale#GetToken('previous_paragraph') . '")<CR>'
execute 'nnoremap <silent> } }:<C-U>call speech#Speak("'
      \ . speech#locale#GetToken('next_paragraph') . '")<CR>'


" MAPPING of f, F, t, T, colon and semicolon.
"nnoremap <silent> , ,:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
"nnoremap <silent> ; ;:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
nnoremap <silent> , :<C-U>call speech#normal_mode#FindCharRepeat(',')<CR>
nnoremap <silent> ; :<C-U>call speech#normal_mode#FindCharRepeat(';')<CR>

nnoremap <silent> f :<C-U>call speech#normal_mode#FindChar('f')<CR>
nnoremap <silent> F :<C-U>call speech#normal_mode#FindChar('F')<CR>
if g:speech#keyboard_layout ==? "neo"
  nnoremap <silent> h :<C-U>call speech#normal_mode#FindChar('t')<CR>
  nnoremap <silent> H :<C-U>call speech#normal_mode#FindChar('T')<CR>
else
  nnoremap <silent> t :<C-U>call speech#normal_mode#FindChar('t')<CR>
  nnoremap <silent> T :<C-U>call speech#normal_mode#FindChar('T')<CR>
endif

" This mapping will called in FindChar.
nmap <expr> <Plug><C-N><C-6> speech#normal_mode#FindCharPart2()


" SECTION Give meta informations, i.e. current line number.
" NOTE Remapping of l depends on my keyboard layout (Neo 2.0). It would be
" stupid on QWERTY.
execute 'nmap '. g:speech#leader_key . ' <Nop>'
execute 'nmap <silent> ' . g:speech#leader_key . 'L :<C-U>call speech#Linenumber()<CR>'
execute 'nmap <silent> ' . g:speech#leader_key . 'P :<C-U>call speech#Position()<CR>'

" SECTION Spelling text of following movement operation.
execute 'nmap <silent> ' . g:speech#leader_key . 'l :<C-U>call speech#Line(v:count1)<CR>'

" Note that yanking set the cursor position on the first yanked character.
" `] can move the cursor to the last yanked character, but this does not help
" in all cases.
" Thus, the following operations are wrapped into a function which preserves 
" the cursor position.

" FUNCTION Keybind1
" Helper function to reduce redundance.
function! s:Keybind1(key, movement)
  " Define layers of complex command in three steps.
  " 1. Vim mapping command + key combination
  let l:mapping_key = 'nnoremap <silent> ' . g:speech#leader_key . a:key

  " 2. Target of mapping. It's a function call prefixed with :<C-U>
  let l:mapping_target = ' :<C-U>call speech#PreserveCursor('
  
  " 3. Argument of target function. It's a function name
  " (speech#Movement) + arguments. The first argument was given to Keybind1.
  " Attention, the whole string is wrapped into single quotes (the "'"-token).
  let l:target_argument = "'" . 'call speech#Movement("'
        \ . a:movement . '",v:count,"")' . "'"
  
  " 4. Closing bracket for step 2 and Return key.
  let l:mapping_target_close = ')<CR>'

  " Put it all together and execute.
  execute l:mapping_key . l:mapping_target 
        \ . l:target_argument . l:mapping_target_close

  " Short form
  "execute 'nnoremap <silent> ' . g:speech#leader_key . a:key
  "      \ . ' :<C-U>call speech#PreserveCursor('."'".'call speech#Movement("' 
  "      \ . a:movement . '",v:count,"")'."'".')<CR>'
endfunction

silent execute 'nnoremap <silent> <expr> ' . g:speech#leader_key . 'w speech#get_text#Word(v:count)'
"call s:Keybind1('w', 'yaw')
call s:Keybind1('W', 'yaW')
call s:Keybind1('c', 'yl')
call s:Keybind1('s', 'yas')
call s:Keybind1('p', 'yap')

call s:Keybind1('[', 'y[[`]')
call s:Keybind1(']', 'y]]')
call s:Keybind1('(', 'y(`]')
call s:Keybind1(')', 'y)')
call s:Keybind1('b', 'yab')

call s:Keybind1('{', 'y{`]')
call s:Keybind1('}', 'y}')
call s:Keybind1('B', 'yaB')

"call s:Keybind1('<', 'y<`]')
call s:Keybind1('<', 'ya<]')
call s:Keybind1('>', 'ya>')
call s:Keybind1('t', 'yat')
call s:Keybind1('"', "ya\\\"")
call s:Keybind1("'", "ya'")


" SECTION Others
" MAPPING Speech last visual selection
nmap <expr> <silent> <leader>s speech#visual_mode#VisualSelectionSpell({}, 0)
nmap <expr> <silent> gv speech#normal_mode#RestorePreviousSelection()

" MAPPING play sound for entering visual modes
nmap <expr> <silent> <C-L><C-L> speech#general#CheckMode('')
nmap <silent> v v<C-L><C-L>
nmap <silent> V V<C-L><C-L>
nmap <silent> <C-V> <C-V><C-L><C-L>

" Older approach. Does not work.
"nnoremap <silent> v :<C-U>call speech#general#CheckMode('v')<CR>v
"nnoremap <silent> v :<C-U>call speech#general#PingMode('v')<CR>v

"Replace cmdline with cmdline in insert mode to improve navigation
" Open command window instead of command line
" Note: Probably, it is impossible to map this on the : Key.
"nnoremap : :<C-F>o
"nnoremap ; :<C-F>o
"Oh, das geht?! Nein, sobald gewisse echos entfernt werden geht das nicht mehr
"nmap <silent> : :<C-F>o


" SECTION Return current Mode
nmap <expr> <silent> <leader>m speech#GetMode(mode())

      
" SECTION Test
"

"nmap <silent> W :<C-U>call speech#get_text#Word(v:count1)<CR>
"nmap <silent> W :<C-U>call speech#motion#Motion_w(v:count)<CR>
nmap <silent> W :<C-U>call speech#motion#GetPositions('test', v:count1, 0)<CR>
"nmap <silent> B :<C-U>call speech#get_text#Wordb(v:count1)<CR>

