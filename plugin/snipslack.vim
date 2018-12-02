scriptencoding utf-8

if exists('g:snipslack#loaded')
  finish
endif

let g:snipslack#loaded = 1

command! -range=% SnipSlack <line1>,<line2>call snipslack#post(expand('%:p'), line('w$'))
