" SECTION Keybindings
"
" MAPPING Speech mode
cmap <leader>m <C-\>espeech#CmdTest('Command Mode')<CR>


" MAPPING Speech content of command line
cmap <leader>s <C-\>espeech#CmdTest(getcmdline())<CR>
