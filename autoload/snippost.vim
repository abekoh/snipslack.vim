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
        \. " -F channels=" . g:snippost_slack_channel
        \. " -H \"Authorization: Bearer " . g:snippost_slack_token . "\""
        \. " https://slack.com/api/files.upload"
  let response = system(command)
  echo response
endfunction

function! snippost#get_github_url(filepath)
  let dirpath = fnamemodify(a:filepath, ':p:h')
  let filename = fnamemodify(a:filepath, ':t')
  " TODO: change destination
  let remote_url = system('cd ' . dirpath . '; git config --get remote.origin.url')
  if v:shell_error > 0
    echo 'command error'
    return
  endif
  if match(remote_url, "http") == 0
    let list = matchlist(remote_url, '\v^(.{-})(.git|)\n$')
    let url = list[1]
  else
    let list = matchlist(remote_url, '\v^git\@(.*):(.{-})(.git|)\n$')
    let url = 'https://' . list[1] . '/' . list[2]
  endif
  let branch = system('cd ' . dirpath . '; git rev-parse HEAD')
  let git_dirpath = system('cd ' . dirpath . '; git rev-parse --show-prefix')
  let url .= '/blob' . branch . '/' . git_dirpath . filename
  echo url
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
