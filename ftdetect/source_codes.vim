" HEADLINE Special speech functions for source code files.

function! AddVimHandlers()
	if exists("g:vimspeech_enabled") == 0
		return ''
	endif
	"This overwrites the autospeak functionality for this keys
	nmap <buffer> <expr> <silent> <C-L><C-3> CommentDetection()
	nnoremap <buffer> <script> n j<C-L><C-3> 
	nnoremap <buffer> <script> r k<C-L><C-3> 
endfunction
	
function! CommentDetection()
	"let line = tr(getline("."), " \t", '')
	let line = getline(".")
	if len(l:line)>0 && l:line[0] == '"'
		call Ssound('bell_mid.wav')
	endif
	return '' 
endfunction
	

au BufNewFile,BufRead *.vim call AddVimHandlers()

