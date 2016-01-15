" HEADLINE Global values

" SECTION Vim-speech variables. Definitions are sometimes multiline. 
"" This enable/disable speech.
let g:speech = get(g:, 'speech', 1)

"" Default speech language
let g:speech#language = get(g:, 'speech#language', 'en')

"" Keyword for used speech synthesis engine
let g:speech#engine = get(g:, 'speech#engine', 'espeak')

"" Main key for speech commands of this plugin.
" A good choice depends on your keyboard layout.
" Recommendation for QWERTY layout: 's'
" Recommendation for QWERTZ layout: 's'
" Recommendation for Neo2.0 layout: 'l'
" Recommendation for Dworak layout: '?'
let g:speech#leader_key = get(g:, 'speech#leader_key', 'l')

"" Root directory of plugin. Required to find sound snippets.
let g:speech#root_dir = get(g:, 'speech#root_dir',
      \ '$HOME/.vim/bundle/vim-speech/')

" Internal flag to surpress all audio output.
let g:speech#silent = 0


" SECTION Options for Espeak
"" Further options of espeak
let g:speech#espeak_options = get(g:, 'speech#espeak_options',
      \ '-k 30 -s 140 -a 100')


" SECTION Helper function for plugin loading
if exists("*VimSpeech_Load") == 0
  function! VimSpeech_Load()
    " Load files from the plugin2 directory.
    " The files from plugin2 are not placed in this folder
    " to guarantee the right loading order. Moreover, this
    " allows an easy reload of the whole plug-in during a VIM session.
    let g:speech=1
    let g:speech#enabled=1
    execute 'source ' . g:speech#root_dir . 'plugin/vim-speech.vim'
  endfunction
endif

function! VimSpeech_Active()
  if exists("g:speech") && g:speech == 1
    return 1
  endif
  return 0
endfunction


" Surpress automatic loading if speech variable is missing or not 1.
if VimSpeech_Active() == 0
  let g:speech = 0
  :finish
else
  "call VimSpeech_Load()
  execute 'source ' . g:speech#root_dir . 'plugin2/languagetoken.vim'
  "execute 'source ' . g:speech#root_dir . 'plugin2/functions.vim'
  execute 'source ' . g:speech#root_dir . 'plugin2/autospeak.vim'
  "execute 'source ' . g:speech#root_dir . 'plugin2/audiomarks.vim'
  execute 'source ' . g:speech#root_dir . 'plugin2/modules.vim'
  "execute 'source ' . g:speech#root_dir . 'plugin/tests.vim'
endif


