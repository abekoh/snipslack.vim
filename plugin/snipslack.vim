scriptencoding utf-8

if exists('g:snipslack#loaded_snipslack')
  finish
endif

let g:snipslack#loaded_snipslack = 1

command! -range=% PostSlack <line1>,<line2>call snipslack#post_slack(expand('%:p'), line('w$'))
command! GetURL call snipslack#get_github_url('/Users/abekoh/dotfiles/config/nvim/dein.toml')
