# snipslack.vim

Post snippet from vim/neovim to Slack, instancely!

![snipslack_gif](https://user-images.githubusercontent.com/20609790/49587696-fcbe8880-f9a7-11e8-8927-4395caa27cd5.gif)

There are 3 features:
- Post with no options instancely.
- With file name, line number and file-type syntax
- Put GitHub URL as a comment (If remote repository is on Github)

## Requirements

- Vim 8.0 or Neovim
- `curl` command
- `git` command (to get GitHub remote URL)

## Installation

[dein.vim](https://github.com/Shougo/dein.vim):
```
call dein#add('abekoh/snipslack.vim')
```

[vim-plug](https://github.com/junegunn/vim-plug):
```
Plug 'abekoh/snipslack.vim'
```

## Setup

You have to prepare a Slack token for [files.upload](https://api.slack.com/methods/files.upload) API.

Steps to get a token (last updated at Dec. 2, 2018):

1. Access https://api.slack.com/apps, click "Create New App" and create an app in your workspace (or use existed app).
1. Click "OAuth & Permissions", find Scopes, select "Upload and modify files as user (files:write:user)". After, click "Save Changes".
1. Scroll to top, click "Install App to Workspace" and authorize.
1. Then you can get "Oauth Access Token".

If you got a token, add following into your Vim/Neovim config file.
```
let g:snipslack_token = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

Note: this config should not be open to the public. Handle this with care.

And you have to set channel to post snippet. If post to #snippets, like this:
```
let g:snipslack_default_channel = '#snippets'
```

If you want to post as DM, like this:
```
let g:snipslack_default_channel = '@abekoh'
```

Now setup is finished, you are able to post snippets.

## Usage

If you want to post all of current buffer, use like this:
```
:SnipSlack
```

If you want to post a part of current buffer, select with visual mode and type
above command. As a result command will be like this:
```
:'<,'>SnipSlack
```
If it succeeds, you can see snippet in Slack channel that you configured.

## Configuration

Limit of snippet's line. Default: `1000`
```
g:snipslack_limit_lines = 500
```

Enable to post with GitHub URL. If set 0 to disable. Default: `1`
```
g:snipslack_enable_github_url = 0
```

List of git's remote names. When get GitHub URL, search from head of this list. 
Default: `['origin']`
```
g:snipslack_github_remotes = ['origin', 'second']
```

List of remote git service domains. You can set domains that is compatible to GitHub, like GitHub Enterprise.
Default: `['github.com']`
```
g:snipslack_github_domains = ['github.com', 'my.github.enterprise.jp']
```

## Thanks
- [vital.vim](https://github.com/vim-jp/vital.vim)
- [vital-Whisky](https://github.com/lambdalisue/vital-Whisky)
