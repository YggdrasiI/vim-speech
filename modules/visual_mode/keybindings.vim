" SECTION Autospeak
" MAPPING Speech Mode
vmap <expr> <silent> <leader>m Sget_mode(mode())

" MAPPING Speech current selection. Truncate on ends if long
vmap <expr> <silent> <leader>s VisualSelectionSpell({'max_number_of_words': 10}, 0)

" SUBSECTION Movements
" Approach: Call a expr key binding after changes of the visual selection
vmap <expr> <C-L><C-V> VisualSelectionSpell({}, 0)
vmap <expr> <C-L><C-1> VisualSelectionSwapSelectedEnd1()
vmap <expr> <C-L><C-2> VisualSelectionSwapSelectedEnd2()

" MAPPING Movements
vmap <silent> w w<C-L><C-V>
vmap <silent> W W<C-L><C-V>
vmap <silent> b b<C-L><C-V>
vmap <silent> B B<C-L><C-V>
vmap <silent> e e<C-L><C-V>
vmap <silent> E E<C-L><C-V>
vmap <silent> ge ge<C-L><C-V>
vmap <silent> gE gE<C-L><C-V>

" MAPPING Swap selected end of selection
"vmap <silent> o <C-L><C-1>o<C-L><C-2>
vnoremap <C-L><C-3> o
vmap  <silent> o <C-L><C-1><C-L><C-3><C-L><C-2>

