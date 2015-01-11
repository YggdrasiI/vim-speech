" FUNCTION Wrap gv command which restores the previous visual selection
function! RestorePreviousSelection()
		"call Espeak( VimspeakLocaleToken('selection_restore') )
		" or
		call Sping_mode(visualmode())
return 'gv'
endfunction
