# vim-fileheader

A small Vim plugin that inserts a file header for selected file types and keeps the
`Last modified` timestamp up to date.

## Features

- Automatically inserts a header for new files (`BufNewFile`) matching these extensions:
  - `*.sh`, `*.conf`, `*.service`, `*.timer`, `*.info`
- Provides a manual command to insert a header into the current buffer:
  - `:AddHeader`
- Updates the `Last modified:` line on save (`BufWritePre`) **only** when:
  - the buffer is actually modified, and
  - a header is present in the file
- Path formatting:
  - Files inside your home directory are shown as `~/...` (no username shown)
  - Files outside `$HOME` keep their absolute path (e.g. `/etc/...`)

## Installation

### Vim packages
Create directory-tree and clone the repo:
```bash
mkdir -p ~/.vim/pack/helpers/start
cd ~/.vim/pack/helpers/start
git clone https://github.com/hasmaneuroda/vim-fileheader.git
```

Or manually put the plugin file here:

- `~/.vim/pack/helpers/start/vim-fileheader/plugin/fileHeader.vim`

Vim loads packages under `pack/*/start/*` automatically on startup.

### Using a plugin manager (vim-plug for example)
If you use a plugin manager like `vim-plug` simply add
the following lines to your `~/.vimrc`:
```vim
call plug#begin('~/.vim/plugged')
Plug 'hasmaneuroda/vim-file-header'
call plug#end()
```

### Optional packages

If you keep it under `pack/*/opt/*`, you must load it manually, e.g. in `~/.vimrc`:

```vim
packadd vim-fileheader
```

## Usage

### Automatic header insertion

Create a new file matching one of the configured extensions, e.g.:

- `vim new-script.sh`
- `vim my.service`

The header is inserted automatically.

Shell scripts:
- If the file already starts with a shebang (`#!...`), the header is inserted **after** it.
- If no shebang exists, `#!/usr/bin/env bash` is prepended and the header follows.

### Manual header insertion (`:AddHeader`)

To insert a header into the current buffer (including existing files), run:

```vim
:AddHeader
```

### Do I need to put `command! AddHeader call InsertHeader()` into `~/.vimrc`?

No.  
This plugin already defines the `:AddHeader` command inside the plugin file, so you do
**not** need to define it again in `~/.vimrc` when the plugin is installed properly.

You only need a `command!` line in `~/.vimrc` if you are **not** using the plugin as a
plugin file (for example, if you copied only the function(s) into your `~/.vimrc` and
did not install the plugin under `pack/.../start/...` or otherwise load it).

## Customization

To change which file types get an automatic header, edit the `BufNewFile` pattern list
in `plugin/fileHeader.vim`, for example:

```vim
autocmd BufNewFile *.sh,*.conf,*.service,*.timer,*.info call s:InsertHeader()
```

To disable automatic insertion entirely, remove or comment out the `BufNewFile` autocmd
block.

## Implementation notes

- The plugin does not use `:substitute` for updating timestamps. This avoids errors
  related to the "previous substitute pattern" state and works reliably regardless of
  how the header was inserted.
- Header detection looks for `# File:` near the top of the file. Timestamp updates only
  touch files that already contain this header marker.
