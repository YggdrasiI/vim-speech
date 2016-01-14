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

" MAPPING object motions 
"nnoremap <silent> ( (:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
"nnoremap <silent> ) ):<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
nnoremap <silent> ( (:<C-U>call speech#Speak("Previous sentence.")<CR>
nnoremap <silent> ) ):<C-U>call speech#Speak("Next sentence.")<CR>
nnoremap <silent> { {:<C-U>call speech#Speak("Previous paragraph.")<CR>
nnoremap <silent> } }:<C-U>call speech#Speak("Next paragraph.")<CR>

nnoremap <silent> s h:<C-U>call speech#PreserveCursor('call speech#Movement("yl",0,"")')<CR>
nnoremap <silent> t l:<C-U>call speech#PreserveCursor('call speech#Movement("yl",0,"")')<CR>

nnoremap <silent> n j:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>
nnoremap <silent> r k:<C-U>call speech#PreserveCursor('call speech#Movement("yiw",0,"")')<CR>


" SECTION Give meta informations, i.e. current line number.
" NOTE Remapping of l depends on my keyboard layout (Neo 2.0). It would be
" stupid on QWERTY.
nmap l <Nop>
nmap <silent> lL :<C-U>call speech#Linenumber()<CR>
nmap <silent> lP :<C-U>call speech#Position()<CR>

" SECTION Spelling text of following movement operation.
nmap <silent> ll :<C-U>call speech#Line(v:count1)<CR>

" Note that yanking set the cursor position on the first yanked character.
" `] can move the cursor to the last yanked character, but this does not help
" in all cases.
" Thus, the following operations are wrapped into a function which preserves 
" the cursor position.
nnoremap <silent> lw :<C-U>call speech#PreserveCursor('call speech#Movement("yaw",v:count,"")')<CR>
nnoremap <silent> lW :<C-U>call speech#PreserveCursor('call speech#Movement("yaW",v:count,"")')<CR>
nnoremap <silent> lc :<C-U>call speech#PreserveCursor('call speech#Movement("yl",v:count,"")')<CR>
nnoremap <silent> ls :<C-U>call speech#PreserveCursor('call speech#Movement("yas",v:count,"")')<CR>
nnoremap <silent> lp :<C-U>call speech#PreserveCursor('call speech#Movement("yap",v:count,"")')<CR>

nnoremap <silent> l[ :<C-U>call speech#PreserveCursor('call speech#Movement("y[[`]",v:count,"")')<CR>
nnoremap <silent> l] :<C-U>call speech#PreserveCursor('call speech#Movement("y]]",v:count,"")')<CR>
nnoremap <silent> l( :<C-U>call speech#PreserveCursor('call speech#Movement("y(`]",v:count,"")')<CR>
nnoremap <silent> l) :<C-U>call speech#PreserveCursor('call speech#Movement("y)",v:count,"")')<CR>
nnoremap <silent> lb :<C-U>call speech#PreserveCursor('call speech#Movement("yab",v:count,"")')<CR>

nnoremap <silent> l{ :<C-U>call speech#PreserveCursor('call speech#Movement("y{`]",v:count,"")')<CR>
nnoremap <silent> l} :<C-U>call speech#PreserveCursor('call speech#Movement("y}",v:count,"")')<CR>
nnoremap <silent> lB :<C-U>call speech#PreserveCursor('call speech#Movement("yaB",v:count,"")')<CR>

"nnoremap <silent> l< :<C-U>call speech#PreserveCursor('call speech#Movement("y<`]",v:count,"")')<CR>
nnoremap <silent> l< :<C-U>call speech#PreserveCursor('call speech#Movement("ya<]",v:count,"")')<CR>
nnoremap <silent> l> :<C-U>call speech#PreserveCursor('call speech#Movement("ya>",v:count,"")')<CR>
nnoremap <silent> lt :<C-U>call speech#PreserveCursor('call speech#Movement("yat",v:count,"")')<CR>
nnoremap <silent> l" :<C-U>call speech#PreserveCursor('call speech#Movement("ya\"",v:count,"")')<CR>
nnoremap <silent> l' :<C-U>call speech#PreserveCursor('call speech#Movement("ya\\\'",v:count,"")')<CR>
nnoremap <silent> lw :<C-U>call speech#PreserveCursor('call speech#Movement("yaw",v:count,"")')<CR>
nnoremap <silent> lW :<C-U>call speech#PreserveCursor('call speech#Movement("yaW",v:count,"")')<CR>
nnoremap <silent> lc :<C-U>call speech#PreserveCursor('call speech#Movement("yl",v:count,"")')<CR>

" SECTION Others
" MAPPING Speech last visual selection
nmap <expr> <silent> <leader>s speech#visual_mode#VisualSelectionSpell({}, 0)
nmap <expr> <silent> gv speech#normal_mode#RestorePreviousSelection()

" MAPPING play sound for entering visual modes
nmap <expr> <silent> <C-L><C-L> speech#general#Checkmode('')
nmap <silent> v v<C-L><C-L>
nmap <silent> V V<C-L><C-L>
nmap <silent> <C-V> <C-V><C-L><C-L>

" Workaround, no does not work, too:
"nnoremap <silent> v :<C-U>call speech#general#Checkmode('v')<CR>v
"nnoremap <silent> v :<C-U>call speech#general#PingMode('v')<CR>v

"Replace cmdline with cmdline in insert mode to improve navigation
" Open command window instead of command line
" Note: Probably, it is impossible to map this on the : Key.
"nnoremap : :<C-F>o
"nnoremap ; :<C-F>o
"Oh, das geht?! Nein, sobald gewisse echos entfernt werden geht das nicht mehr
"nmap <silent> : :<C-F>o


" SECTION Return current Mode
"nmap <leader>m :call Sget_mode(mode())<CR>
nmap <expr> <silent> <leader>m speech#GetMode(mode())
