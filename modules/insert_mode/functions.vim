
"SECTION Speech after each typed word/sentence.
function! InsertModeSpellWord(char)
		if pumvisible() == 0
			call CompleteWordHandler()
		endif
		return a:char
endfunction

function! InsertModeSpellSentence(char)
		if pumvisible() == 0
			let line = ' ' . tr(getline("."), "\t", ' ')
			let curPos = col(".")
			let spaceBefore = max([0,strridx(l:line, a:char, l:curPos-1)])
			let spaceAfter = max([curPos-1, stridx(l:line, a:char, l:spaceBefore)])
			let line = l:line[l:spaceBefore : l:spaceAfter]
			if len(l:line) > 0 
				call Espeak( l:line )
			endif
		endif
		return a:char
endfunction


" SECTION Speech of insert menu popup enties

" Below, we can not use inoremap, but imap. To omit
" a recursion in the <C-N>, <C-P> keybindings we use this variable.
let Popup_action_already_done = 0 " Currently not used
let Popup_state = 0
function! CompleteWordHandler() 
	"no, the cursor is one position behind the word...
	"let wordUnderCursor = expand("<cword>")
	"let line = split(getline(".")) "<-- Falsch, da Länge des Wortes hinter Cursor nicht eingeht?!
	"let line = split(getline(".")[0:col(".")]) "Klappt nicht im inneren von Texten
	let line = ' ' . tr(getline("."), "\t", ' ')
	let curPos = col(".")
	let spaceBefore = strridx(l:line,' ', l:curPos-1)
	let spaceAfter = max([curPos-1, stridx(l:line,' ', l:spaceBefore)])
	let line = l:line[l:spaceBefore : l:spaceAfter]
	"let line = escape(l:line, '"')
	"echo l:line
	if len(l:line) > 0 
		call Espeak( l:line )
	endif
	let g:Popup_action_already_done = 0
	return ''
endfunction

" Remapping of <C-N> and <C-P>. The returned string
" differs between three cases.
" This is required because the keymappings uses the expression-flag <expr> and
" PopupAction will be called recursively. 
" Case 0: Menu is closed. Start opening and play opening sound.
" 				Moreover, send second popup menu command to select 
" Case 1: State during the
" Case 2: Menu open. Call normal menu keybinding and then speak.
function! PopupAction(return0, return1, return2 )
	if g:Popup_state == 2 && pumvisible() == 0
		let g:Popup_state = 0
	endif
	if g:Popup_state == 0
		let g:Popup_state = 1
		return a:return0
	elseif g:Popup_state == 1
		let g:Popup_state = 2
		return a:return1
	else  
		return a:return2
	endif
endfunction

function! StartPopupMenu()
	call Ssound('bell_mid.wav')
	let g:Popup_action_already_done = 0
	return ''
endfunction

function! PopupAction_Next()
		return PopupAction("\<C-N>\<C-P>\<C-1>", "\<C-N>", "\<C-N>\<C-L>")
endfunction

function! PopupAction_Prev()
		return PopupAction("\<C-P>\<C-N>\<C-1>", "\<C-P>", "\<C-P>\<C-L>")
endfunction

function! PopupAction_Abort()
		call Sping_mode('i')
		return "\<C-E>"
endfunction

function! PopupAction_Confirm()
		call Sping_mode('i')
		return "\<C-Y>"
endfunction

