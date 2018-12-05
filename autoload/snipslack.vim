scriptencoding utf-8

if !exists('g:snipslack#loaded')
  finish
endif


let s:Job = vital#snipslack#import('System.Job')
let s:JSON = vital#snipslack#import('Web.JSON')

if !executable('curl')
  echoh ErrorMsg | echom '[snipslack] Please setup ''curl'' command' | echoh None
  finish
endif

if !exists('g:snipslack_token')
  echoh ErrorMsg | echom '[snipslack] Please setup ''g:snipslack_token''' | echoh None
  finish
end

if !exists('g:snipslack_default_channel')
  echoh ErrorMsg | echom '[snipslack] Please setup ''g:snipslack_default_channel''' | echoh None
end

if !exists('g:snipslack_limit_lines')
  let g:snipslack_limit_lines = 1000
end

if !exists('g:snipslack_enable_github_url')
  let g:snipslack_enable_github_url = 1
end

if g:snipslack_enable_github_url is# 1 && !executable('git')
  echoh ErrorMsg | echom '[snipslack] Please setup ''git'' command' | echoh None
  finish
endif

if !exists('g:snipslack_github_remotes')
  let g:snipslack_github_remotes = ['origin']
end

if !exists('g:snipslack_github_domains')
  let g:snipslack_github_domains = ['github.com']
end

function! s:get_github_link(dirpath, filename, range) abort
  let cd_command = 'cd ' . a:dirpath . '; '

  let remote = ''
  let remote_url = ''
  for remote in g:snipslack_github_remotes
    let remote_url = system(cd_command . 'git config --get remote.' . remote . '.url')
    if v:shell_error == 0
      break
    endif
  endfor
  if v:shell_error > 0
    return
  endif

  if match(remote_url, "^http.*$") == 0
    let domain = matchlist(remote_url, '\v^.*\/\/(.*)\/.*$')[1]
    let url = matchlist(remote_url, '\v^(.{-})(.git|)\n$')[1]
  else
    let l = matchlist(remote_url, '\v^.*git\@(.{-})(:|\/)(.{-})(.git|)\n$')
    let domain = l[1]
    let url = 'https://' . domain . '/' . l[3]
  endif

  if match(g:snipslack_github_domains, domain) < 0
    return
  endif

  let branch = system(cd_command . 'git symbolic-ref --short HEAD')
  if v:shell_error > 0
    return
  endif

  let hash = system(cd_command . 'git rev-parse ' . remote . '/' . branch)
  if v:shell_error > 0
    return
  endif

  let git_dirpath = system(cd_command . 'git rev-parse --show-prefix')
  if v:shell_error > 0
    return
  endif

  let url .= '/blob/' . hash . '/' . git_dirpath . a:filename . a:range

  let comment = '<' . url . '|open URL in ' . remote . '/' . branch . '>'
  let comment = substitute(comment, '\n', '', 'g')

  return comment
endfunction

function! s:make_post_command(file, filename, title, github_link) abort
  let command = ['curl', '-s',
        \ '-F', 'file=@' . a:file,
        \ '--form-string', 'filename=' . a:filename,
        \ '--form-string', 'title=' . a:title,
        \ '--form-string', 'channels=' . g:snipslack_default_channel,
        \ '--form-string', 'token=' . g:snipslack_token]
  if a:github_link isnot# ''
    let command += ['--form-string', 'initial_comment=' . a:github_link]
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

  if a:lastline - a:filelastline + 1 > g:snipslack_limit_lines
    echoh ErrorMsg | echom '[snipslack] Error: length of lines is greater than g:snipslack_limit_lines(=' . g:snipslack_limit_lines . ').' | echoh None
    return
  endif

  if a:firstline == 1 && a:lastline == a:filelastline
    if filereadable(a:filepath)
      let file = a:filepath
      let title = filename
    else
      let file = tempname()
      call writefile(getline(1, a:filelastline), file)
      let title = 'untitled'
    end
    let range = ''
  else
    let file = tempname()
    call writefile(getline(a:firstline, a:lastline), file)
    let range = '#L' . a:firstline . '-L' . a:lastline
    let title = filename . range
  endif

  let github_url = ''
  if g:snipslack_enable_github_url is# 1 && filereadable(a:filepath) is# 1
    let github_link = call('s:get_github_link', [dirpath, filename, range])
  end

  let command = call('s:make_post_command', [file, filename, title, github_link])

  call s:Job.start(command, {
    \ 'on_stdout': function('s:echo_success_message'),
    \ 'on_stderr': function('s:echo_failure_message')
    \})
endfunction
