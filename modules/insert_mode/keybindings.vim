
" SECTION Spell last written word
imap <expr> <Space> speech#insert_mode#SpellWord("\<Space>")
" imap <expr> . speech#insert_mode#SpellWord(".")


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

" MAPPING
imap <expr> <C-L><C-W> speech#insert_mode#CompleteWordHandler()
imap <expr> <C-L><C-5> speech#insert_mode#StartPopupMenu()
imap <expr> <C-N> speech#insert_mode#PopupActionNext() 
imap <expr> <C-P> speech#insert_mode#PopupActionPrev()
imap <expr> <C-E> pumvisible() ? speech#insert_mode#PopupActionAbort() : "\<C-E>"
imap <expr> <C-Y> pumvisible() ? speech#insert_mode#PopupActionConfirm() : "\<C-Y>"

