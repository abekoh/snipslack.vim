scriptencoding utf-8

if exists('g:snippost#loaded_snippost')
  finish
endif

let g:snippost#loaded_snippost = 1

command! -range=% PostSlack <line1>,<line2>call snippost#post_slack(expand('%:t'), line('w$'))

" command! PostSlack call snippost#post_slack_2(expand('%:p'))
