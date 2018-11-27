scriptencoding utf-8

if !exists('g:snipslack#loaded')
  finish
endif

let s:Job = vital#snipslack#import('System.Job')
let s:JSON = vital#snipslack#import('Web.JSON')

function! s:make_post_command(file, filename, title, github_url) abort
  let command = ['curl', '-s',
        \ '-F', 'file=@' . a:file,
        \ '-F', 'filename=' . a:filename,
        \ '-F', 'title=' . a:title,
        \ '-F', 'channels=' . g:snipslack_channel,
        \ '-F', 'token=' . g:snipslack_token]
  if a:github_url isnot# ''
    let command += ['-F', 'initial_comment="<' . a:github_url . '|Remote URL">']
  endif
  let command += ['https://slack.com/api/files.upload']
  return command
endfunction

function! s:echo_success_message(stdout) abort
  let decoded = s:JSON.decode(a:stdout[0])
  if decoded['ok'] is# 1
    echom printf('Success posting to Slack! (%s)', decoded['file']['permalink'])
  else
    echom printf('Error: %s', decoded['error'])
  endif
endfunction

function! s:echo_failure_message(stderr) abort
  echom printf('Failed: %s', a:stderr[0])
endfunction

function! s:get_github_url(filepath) abort
  let dirpath = fnamemodify(a:filepath, ':p:h')
  let filename = fnamemodify(a:filepath, ':t')
  let cd_command = 'cd ' . dirpath . '; '
  let remote_url = system(cd_command . 'git config --get remote.origin.url')
  if v:shell_error > 0
    return
  endif
  if match(remote_url, "^http.*$") == 0
    let host = matchlist(remote_url, '\v^.*\/\/(.*)\/.*$')[1]
    let url = matchlist(remote_url, '\v^(.{-})(.git|)\n$')[1]
  else
    let l = matchlist(remote_url, '\v^.*git\@(.{-})(:|\/)(.{-})(.git|)\n$')
    let host = l[1]
    let url = 'https://' . host . '/' . l[3]
  endif
  if match(g:snipslack_host_list, host) < 0
    return
  endif
  let branch = system(cd_command . 'git rev-parse HEAD')
  if v:shell_error > 0
    return
  endif
  let git_dirpath = system(cd_command . '; git rev-parse --show-prefix')
  if v:shell_error > 0
    return
  endif
  let url .= '/blob/' . branch . '/' . git_dirpath . filename
  let url = substitute(url, '\n', '', 'g')
  return url
endfunction

function! snipslack#post(filepath, filelastline) range abort
  " set posting file/filename/title
  let filename = fnamemodify(a:filepath, ':t')
  if a:firstline == 1 && a:lastline == a:filelastline
    let file = a:filepath
    let title = filename
  else
    let file = tempname()
    call writefile(getline(a:firstline, a:lastline), file)
    let title = printf('%s#L%d-L%d', filename, a:firstline, a:lastline)
  endif
  let github_url = call('s:get_github_url', [a:filepath])
  " make post command
  let command = call('s:make_post_command', [file, filename, title, github_url])
  " run command
  call s:Job.start(command, {
    \ 'on_stdout': function('s:echo_success_message'),
    \ 'on_stderr': function('s:echo_failure_message')
    \})
endfunction
