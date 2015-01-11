function! Test()
	call feedkeys('j','n') " Setzt erst nach Ende der Funktion die Befehle um.
	let line = getline('.')
	echom l:line
endfunction

" Bad version. setpos of cursor does not work for 'yiw' yanking
function! TestWrapper1()
	let l:curpos = getpos(".")
	execute 'normal! "s' . 'yiw'  
	let l:msg = @s
	echom l:msg
	call setpos (".", l:curpos )
	return ''
endfunction

" This actually works
function! TestWrapper2()
	let l:curpos = getpos("`s")
	execute 'normal! ms"s' . 'yiw' . '`s' 
	let l:msg = @s
	echom l:msg
	call setpos ("'s", l:curpos )
	return ''
endfunction

" This works, too. Found in
" https://groups.google.com/forum/#!searchin/vim_dev/setpos/vim_dev/kydw6-vTuvM/NSnKkPVVnuwJ
function! TestWrapper3()
	let l:view = winsaveview()
	execute 'normal! "s' . 'yiw' 
	let l:msg = @s
	echom l:msg
	call winrestview(l:view)
	return ''
endfunction

