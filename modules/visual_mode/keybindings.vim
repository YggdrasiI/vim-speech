" NOTE Remapping of l depends on my keyboard layout (Neo 2.0). It would be
" stupid on QWERTY.
vmap l <Nop>

" MAPPING Speech Mode
vmap <expr> <silent> <leader>m speech#GetMode(mode())
vmap <expr> <silent> <leader>l speech#Line(v:count1)
"vmap <silent> <leader>l :<C-U>call speech#Line(v:count1)<CR> "Wrong

" MAPPING Speech current selection. Truncate on ends if long
vmap <expr> <silent> <leader>s speech#visual_mode#VisualSelectionSpell({'max_number_of_words': 10}, 0)

" SECTION Autospeak
" SUBSECTION Movements
" Approach: Call a expr key binding after changes of the visual selection
vmap <expr> <C-L><C-V> speech#visual_mode#VisualSelectionSpell({}, 0)
vmap <expr> <C-L><C-1> speech#visual_mode#VisualSelectionSwapSelectedEnd1()
vmap <expr> <C-L><C-2> speech#visual_mode#VisualSelectionSwapSelectedEnd2()
vmap <expr> <C-L><C-3> speech#visual_mode#VisualSelectionLineNumbers()
vmap <expr> <C-L><C-4> speech#visual_mode#VisualSelectionSpellChar()

" MAPPING wordwise movements
vmap <silent> w w<C-L><C-V>
vmap <silent> W W<C-L><C-V>
vmap <silent> b b<C-L><C-V>
vmap <silent> B B<C-L><C-V>
vmap <silent> e e<C-L><C-V>
vmap <silent> E E<C-L><C-V>
vmap <silent> ge ge<C-L><C-V>
vmap <silent> gE gE<C-L><C-V>

" MAPPING navigation movements
vmap <silent> s h<C-L><C-4>
vmap <silent> n j<C-L><C-3>
vmap <silent> r k<C-L><C-3>
vmap <silent> t l<C-L><C-4>

" MAPPING Swap selected end of selection
"vmap <silent> o <C-L><C-1>o<C-L><C-2>
vnoremap <C-L><C-8> o
vmap  <silent> o <C-L><C-1><C-L><C-8><C-L><C-2>
"vnoremap <C-L><C-9> O
"vmap  <silent> O <C-L><C-1><C-L><C-9><C-L><C-2>


" MAPPING play sound for change visual mode
vmap <expr> <silent> <C-L><C-L> speech#general#CheckMode('')
vmap <silent> v v<C-L><C-L>
vmap <silent> V V<C-L><C-L>
vmap <silent> <C-V> <C-V><C-L><C-L>

" MAPPING play sound if visual mode will be leaved
" Note: Do not remap the commands which enter the
" insert mode. They will be handled by the InsertEnter event.
vmap <silent> <ESC> <ESC><C-L><C-L>
vmap <silent> <C-C> <C-C><C-L><C-L>
vmap <silent> d d<C-L><C-L>
vmap <silent> y y<C-L><C-L>
vmap <silent> Y Y<C-L><C-L>

