" Just testing code...

let VimspeakBufferName = '__vimspeak_buffer__'
" ScratchMarkBuffer
" Mark a buffer as scratch
function! s:ScratchMarkBuffer()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal buflisted
endfunction

"Initialisation of hidden buffer 
function! Sinit()
  " Disallow speaking during initialisation
  let g:speech#silent = 1
  let g:speech#bufnum = bufnr(g:VimspeakBufferName, 1)

  let g:speech#silent = 0
endfunction

function! CloseHiddenBuffer()
  let tmpbufnum = bufnr('__vimspeak_buffer__', 1)
  silent! bd! l:tmpbufnum
endfunction

autocmd BufNewFile __vimspeak_buffer__ call s:ScratchMarkBuffer()
autocmd VimLeavePre * call CloseHiddenBuffer()

call Sinit()
