" SECTION Description
" This file contains a two dimensional dictionary with
" language locales.
" Some strings will be used as format strings for the vim version of the printf command.
" Use the function speech#language#GetToken('key') to fetch the string in the
" globally selected languge.
" The globally selected language is set by the variable g:speech#language.


" SECTION Related files
" autoload/speech/locale.vim


" SECTION Variables
let g:vs_langs = {
  \ 'filename': {
    \ 'en': 'Filename: %s ',
    \ 'de': 'Dateiname: %s '},
  \ 'line': {
    \ 'en': 'Line ',
    \ 'de': 'Zeile '},
  \ 'selection_line_range': {
    \ 'en': 'Selection from line %d to %d ',
    \ 'de': 'Auswahl von Zeile %d bis %d '},
  \ 'character': {
    \ 'en': 'Character ',
    \ 'de': 'Zeichen '},
  \ ' ': {
    \ 'en': 'Space',
    \ 'de': 'Leerzeichen'},
  \ 'selection_cursor_at_start': {
    \ 'en': 'Cursor on begin of selection. ',
    \ 'de': 'Anfang der Auswahl. '},
  \ 'selection_cursor_at_end': {
    \ 'en': 'Cursor on end of selection. ',
    \ 'de': 'Ende der Auswahl. '},
  \ 'selection_single_character': {
    \ 'en': 'Selection contains just one character. ',
    \ 'de': 'Auswahl enthält nur ein Zeichen. '},
  \ 'selection_restore': {
    \ 'en': 'Restore previous selection. ',
    \ 'de': 'Vorherige Auswahl wiederhergestellt. '},
  \ 'available_speech_engines': {
    \ 'en': 'Available enignes: %s. Set g:speech#engine too use one of them as default output. Some su    broutines my override this setting. ',
    \ 'de': 'Verfügbare Sprachprogramme: %s. Setze die Variable g:speech#engine auf einen dieser Werte. Einige Unterfunktionen können diesen Wert allerdings ignorieren. '},
  \ 'next_sentence': {
    \ 'en': 'Next sentence. ',
    \ 'de': 'Nächster Satz. '},
  \ 'previous_sentence': {
    \ 'en': 'Previous sentence. ',
    \ 'de': 'Vorheriger Satz. '},
  \ 'next_paragraph': {
    \ 'en': 'Next paragraph. ',
    \ 'de': 'Nächster Absatz. '},
  \ 'previous_paragraph': {
    \ 'en': 'Previous sentence. ',
    \ 'de': 'Vorheriger Absatz. '},
  \ 'selection_range': {
    \ 'en': '%s from %s',
    \ 'de': '%s bis %s'},
  \ 'selection_range_from': {
    \ 'en': 'from %s to %s',
    \ 'de': 'von %s bis %s'},
  \ 'dummy entry': {
    \ 'en': 'example entry for copy and paste. ',
    \ 'de': 'Beispieleintrag zum Kopieren. '},
  \ }

"SUBSECTION Special characters
" The value of regex should be a regular experession for this character.
" Note " that the regular expression for the newline contains both variants,
" \r\n and \n.

"  \ ' ': {
"    \ 'regex': '[ ]',
"    \ 'en': 'Space',
"    \ 'de': 'Leerzeichen', },
let g:vs_characters = {
  \ '\t': {
    \ 'regex': '[\t]',
    \ 'en': 'Tabulator',
    \ 'de': 'Tabulator', },
  \ '(': {
    \ 'regex': '[(]',
    \ 'en': 'left paranthese',
    \ 'de': 'Klammer auf', },
  \ ')': {
    \ 'regex': '\([)]\)',
    \ 'en': 'right paranthese',
    \ 'de': 'Klammer zu', },
  \ '{': {
    \ 'regex': '[{]',
    \ 'en': 'left brace',
    \ 'de': 'Geschweifte Klammer auf', },
  \ '}': {
    \ 'regex': '[}]',
    \ 'en': 'right brace',
    \ 'de': 'Geschweifte Klammer zu', },
  \ '<': {
    \ 'regex': '[<]',
    \ 'en': 'left chevron',
    \ 'de': 'Spitze Klammer auf', },
  \ '>': {
    \ 'regex': '>',
    \ 'en': 'right chevron',
    \ 'de': 'Spitze Klammer zu', },
  \ ']': {
    \ 'regex': '[\]]',
    \ 'en': 'right bracket',
    \ 'de': 'Eckige Klammer zu', },
  \ '\': {
    \ 'regex': '[\\]',
    \ 'en': 'backslash',
    \ 'de': 'Backslash', },
  \ '"': {
    \ 'regex': '["]',
    \ 'en': 'double quote',
    \ 'de': 'Doppeltes Anführungszeichen', },
  \ "'": {
    \ 'regex': "'",
    \ 'en': 'single quote',
    \ 'de': 'Einfaches Anführungszeichen', },
  \ ',': {
    \ 'regex': '[,]',
    \ 'en': 'comma',
    \ 'de': 'Komma', },
  \ '.': {
    \ 'regex': '[.]',
    \ 'en': 'dot',
    \ 'de': 'Punkt', },
  \ ':': {
    \ 'regex': '[:]',
    \ 'en': 'colon',
    \ 'de': 'Doppelpunkt', },
  \ ';': {
    \ 'regex': '[;]',
    \ 'en': 'semicolon',
    \ 'de': 'Semikolon', },
  \ '-': {
    \ 'regex': '[-]',
    \ 'en': 'hyphen',
    \ 'de': 'Bindestrich', },
  \ '`': {
    \ 'regex': '[`]',
    \ 'en': 'back-tick',
    \ 'de': 'Gravis', },
  \ '!': {
    \ 'regex': '[!]',
    \ 'en': 'bang',
    \ 'de': 'Ausrufezeichen', },
  \ '?': {
    \ 'regex': '[?]',
    \ 'en': 'question mark',
    \ 'de': 'Fragezeichen', },
  \ '\n': {
    \ 'regex': '[\n][\r]\{0,1\}',
    \ 'en': 'new line',
    \ 'de': 'Zeilenumbruch', },
  \ '[': {
    \ 'regex': '[[]',
    \ 'en': 'left bracket',
    \ 'de': 'Eckige Klammer auf', },
  \ '/': {
    \ 'regex': '[\/]',
    \ 'en': 'slash',
    \ 'de': 'Slash', },
  \ '#': {
    \ 'regex': '[#]',
    \ 'en': 'hash',
    \ 'de': 'Raute', },
  \ '$': {
    \ 'regex': '[$]',
    \ 'en': 'dollar',
    \ 'de': 'Dollar', },
  \ '€': {
    \ 'regex': '[€]',
    \ 'en': 'euro',
    \ 'de': 'Euro', },
  \ 'α': { 
    \ 'regex': '[α]',
    \ 'en': 'alpha',
    \ 'de': 'Alpha', },
  \ '•': { 
    \ 'regex': '[•]',
    \ 'en': 'bullet',
    \ 'de': 'Aufzählungspunkt', },
  \ 'dummy': {
    \ 'regex': '[d][u][m][m][y]',
    \ 'en': ' ',
    \ 'de': ' ', },
    \ }
