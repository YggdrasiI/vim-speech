" FUNCTION StartCommand
" Sound for command line start. I assume this affects scripts, too.
function! speech#command_line#StartCommandLine(key)
  call speech#sound#Play('command.wav')
  echom "Foo"
  return a:key
endfunction

