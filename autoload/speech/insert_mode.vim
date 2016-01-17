" SECTION Wrapper function for speak during normal typing of text.

" FUNCTION SpellWord
" Speech after each typed word/sentence.
"
function! speech#insert_mode#SpellWord(char)
  if pumvisible() == 0
    call speech#insert_mode#CompleteWordHandler()
  endif
  return a:char
endfunction


" FUNCTION SpellSenctence
"
function! speech#insert_mode#SpellSentence(char)
  if pumvisible() == 0
    let line = ' ' . tr(getline("."), "\t", ' ')
    let curPos = col(".")
    let spaceBefore = max([0,strridx(l:line, a:char, l:curPos-1)])
    let spaceAfter = max([curPos-1, stridx(l:line, a:char, l:spaceBefore)])
    let line = l:line[l:spaceBefore : l:spaceAfter]
    if len(l:line) > 0 
      call speech#Speak( l:line )
    endif
  endif
  return a:char
endfunction


" SECTION Speech of insert menu popup entries. Warning, this is more
" complicated as aspected due VIMs handling of text completion menus.

" Below, we can not use inoremap, but imap. To omit
" a recursion in the <C-N>, <C-P> keybindings we use this variable.
let Popup_action_already_done = 0 " Currently not used
let Popup_state = 0
function! speech#insert_mode#CompleteWordHandler() 
  " 1. Get word of completion.

  " Following line would be wrong. The cursor is one position behind the word.
  " A few wrong approaches...
  "let wordUnderCursor = expand("<cword>") " Wrong. Cursor is behend the word.
  "let line = split(getline(".")) " Wrong, does not respect word length after cursor.
  "let line = split(getline(".")[0:col(".")]) " Does not work inside of textes.

  " Now, the best one approach.
  let line = ' ' . tr(getline("."), "\t", ' ')
  let curPos = col(".")
  let spaceBefore = strridx(l:line,' ', l:curPos-1)
  let spaceAfter = max([l:curPos-1, stridx(l:line,' ', l:spaceBefore)])
  let line = l:line[l:spaceBefore : l:spaceAfter]

  " Add space to omit error for string '\'.
  let line = l:line . ' '

  if len(l:line) > 0 
    call speech#Speak( l:line )
  endif
  let g:Popup_action_already_done = 0
  return ''
endfunction


" FUNCTION PopupAction
" Remapping of <C-N> and <C-P>. The returned string
" differs between three cases.
" This is required because the keymappings uses the expression-flag <expr> and
" PopupAction will be called recursively. 
" Case 0: Menu is closed. Start opening and play opening sound.
"         Moreover, send second popup menu command to select 
" Case 1: State during the
" Case 2: Menu open. Call normal menu keybinding and then speak.
"
function! speech#insert_mode#PopupAction(return0, return1, return2 )
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


" FUNCTION StartPopupMenu
"
function! speech#insert_mode#StartPopupMenu()
  call speech#sound#Play('bell_mid.wav')
  let g:Popup_action_already_done = 0
  return ''
endfunction


" FUNCTION PoupActionNext
"
function! speech#insert_mode#PopupActionNext()
  return speech#insert_mode#PopupAction("\<C-N>\<C-P>\<C-L>\<C-5>", "\<C-N>", "\<C-N>\<C-L>\<C-W>")
endfunction


" FUNCTION PoupActionPrev
"
function! speech#insert_mode#PopupActionPrev()
  return speech#insert_mode#PopupAction("\<C-P>\<C-N>\<C-L>\<C-5>", "\<C-P>", "\<C-P>\<C-L>\<C-W>")
endfunction


" FUNCTION PoupActionAbort
"
function! speech#insert_mode#PopupActionAbort()
  call speech#general#PingMode('i')
  return "\<C-E>"
endfunction


" FUNCTION PopupActionConfirm
"
function! speech#insert_mode#PopupActionConfirm()
  call speech#general#PingMode('i')
  return "\<C-Y>"
endfunction


