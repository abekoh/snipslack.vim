scriptencoding utf-8

if !exists('g:snippost#loaded_snippost')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

function! snippost#post_slack(filepath, filelastline) range
  let filename = fnamemodify(a:filepath, ':t')
  if a:firstline == 1 && a:lastline == a:filelastline
    let file = a:filepath
    let title = filename
  else
    let file = tempname()
    call writefile(getline(a:firstline, a:lastline), file)
    let title = printf('%s#L%d-L%d', filename, a:firstline, a:lastline)
  endif
  let command = "curl -s -F file=@" . file
        \. " -F filename=" . filename
        \. " -F title=" . title
        \. " -F channels=#general"
        \. " -H \"Authorization: Bearer " . g:snippost_slack_token . "\""
        \. " https://slack.com/api/files.upload"
  let response = system(command)
  echo response
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
