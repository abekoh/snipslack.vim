# snipslack.vim

Post snippet from vim/neovim to Slack, instancely!

## Features


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

If you got a token, add following into your vim/neovim setting file.
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
