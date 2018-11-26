scriptencoding utf-8

if exists('g:snipslack#loaded')
  finish
endif

let g:snipslack#loaded = 1

command! -range=% PostSlack <line1>,<line2>call snipslack#post(expand('%:p'), line('w$'))
command! GetURL call snipslack#get_github_url('/Users/abekoh/dotfiles/config/nvim/dein.toml')
