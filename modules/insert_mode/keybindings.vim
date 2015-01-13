
" SECTION Spell last written word
imap <expr> <Space>  InsertModeSpellWord("\<Space>")
"imap <expr> . InsertModeSpellSentence(".")


" SECTION Popup menu
" Open menu if just one word match. Otherwise, the menu will neither open nor
" spoken.
set completeopt=menuone

" It is not possible to call ex-mode commands in insert mode without leaving
" the insert mode which closes the menu.
" Thus, we need to use the <expr> way to call a function.
" Bug: No speech for first call of i_Ctrl-N.
" Problem: inoremap does not work due <C-1> is a new mapping
" Todo: Add other key combinations, see help of popupmenu-keys for a list of
" available keys.
imap <expr> <C-L><C-W> CompleteWordHandler()
imap <expr> <C-L><C-5> StartPopupMenu()
imap <expr> <C-N> PopupAction_Next() 
imap <expr> <C-P> PopupAction_Prev()
imap <expr> <C-E> pumvisible() ? PopupAction_Abort() : "\<C-E>"
imap <expr> <C-Y> pumvisible() ? PopupAction_Confirm() : "\<C-Y>"

