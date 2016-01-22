" SECTION Keybindings
"
" MAPPING Speech mode
cmap <silent> <leader>m <C-\>espeech#CmdTest('Command Mode')<CR>


" MAPPING Speech content of command line
cmap <silent> <leader>s <C-\>espeech#CmdTest(getcmdline())<CR>

" SECTION Search
nnoremap <expr> / speech#command_line#StartSearch('/')
nnoremap <expr> ? speech#command_line#StartSearch('?')


" SECTION Test
nnoremap <expr> : speech#command_line#StartCommandLine(':')

" Bug: This hide imideatly the output of the cmd window.
"cmap <silent> <CR> <CR><Plug>EndCmd
"cmap <expr> <Plug>EndCmd speech#command_line#Ignore()
"nmap <expr> <Plug>EndCmd speech#command_line#EndCommandLine()

" This event is not invoked for command line.
"autocmd ShellCmdPost * call speech#sound#Play('bell_church.wav')

"autocmd User MyCustomEvent call my_custom_function()
"doautocmd User MyCustomEvent
