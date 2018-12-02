scriptencoding utf-8

if !exists('g:snipslack#loaded')
  finish
endif

if !executable('curl')
  echoh ErrorMsg | echom '[snipslack] Please setup ''curl'' command' | echoh None
  finish
endif

if !exists('g:snipslack_token')
  echoh ErrorMsg | echom '[snipslack] Please setup ''g:snipslack_token''' | echoh None
  finish
end

if !exists('g:snipslack_channel')
  echoh ErrorMsg | echom '[snipslack] Please setup ''g:snipslack_channel''' | echoh None
end

if !exists('g:snipslack_enable_github_url')
  let g:snipslack_enable_github_url = 1
end

if !exists('g:snipslack_github_domains')
  let g:snipslack_github_domains = ['github.com']
end

let s:Job = vital#snipslack#import('System.Job')
let s:JSON = vital#snipslack#import('Web.JSON')

function! s:get_github_url(dirpath, filename) abort
  let cd_command = 'cd ' . a:dirpath . '; '
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
  let url .= '/blob/' . branch . '/' . git_dirpath . a:filename
  let url = substitute(url, '\n', '', 'g')
  return url
endfunction

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
    echom '[snipslack] Success! ' . decoded['file']['permalink']
  else
    echoh ErrorMsg | echom '[snipslack] Failed: ' . decoded['error'] | echoh None
  endif
endfunction

function! s:echo_failure_message(stderr) abort
  echoh ErrorMsg | echom '[snipslack] Failed: ' . a:stderr[0] | echoh None
endfunction

function! snipslack#post(filepath, filelastline) range abort
  let filename = fnamemodify(a:filepath, ':t')
  let dirpath = fnamemodify(a:filepath, ':p:h')

  if a:firstline == 1 && a:lastline == a:filelastline
    if filereadable(a:filepath)
      let file = a:filepath
      let title = 'untitled'
    else
      let file = tempname()
      call writefile(getline(1, a:filelastline), file)
      let title = filename
    end
  else
    let file = tempname()
    call writefile(getline(a:firstline, a:lastline), file)
    let title = printf('%s#L%d-L%d', filename, a:firstline, a:lastline)
  endif

  let github_url = ''
  if g:snipslack_enable_github_url is# 1
    let github_url = call('s:get_github_url', [dirpath, filename])
  end

  let command = call('s:make_post_command', [file, filename, title, github_url])

  call s:Job.start(command, {
    \ 'on_stdout': function('s:echo_success_message'),
    \ 'on_stderr': function('s:echo_failure_message')
    \})
endfunction
