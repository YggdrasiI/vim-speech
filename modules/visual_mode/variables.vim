" SECTION Settings for speech of selected text.
" Meaning of variables:
" max_number_of_words - Longer selection will not spelled complete.
" substring_both_sides - if 1 beginning and end of selection will be spoken.
" substring_words_begin - Spoken number at selection begin if cursor moved word-wise.
" substring_words_end - Spoken number at selection end if cursor moved word-wise.
let g:vs_visual_selection_settings_defaults = {
            \ 'max_number_of_words': 5,
            \ 'substring_both_sides': 0,
            \ 'substring_words_begin': 2,
            \ 'substring_words_end': 2,
            \ }

let g:vs_visual_selection_settings_last = g:vs_visual_selection_settings_defaults
