# vim-file-header

A small Vim plugin that automatically inserts a file header into new files and keeps a “Last modified” timestamp up to date.  
For shell scripts (`*.sh`), it also ensures a proper shebang at the top of the file.

## Features

- Automatically inserts a header for new files matching configurable patterns  
- Header includes:
  - File name
  - Path (with `$HOME` instead of `/home/username` if applicable)
  - Created timestamp
  - Last modified timestamp
- Automatically updates the `Last modified` line on every write
- Special handling for `*.sh` files:
  - Adds `#!/usr/bin/env bash` if no shebang is present
  - Inserts the header below an existing shebang
- Manual command to add a header to existing files
- Simple, single-file plugin

Example header for a shell script:

```text
#!/usr/bin/env bash

############################################################
# File:          example.sh
# Path:          $HOME/projects/example.sh
# Created:       2025-12-01 17:45
# Last modified: 2025-12-01 17:45
############################################################
```

Example header for a config file:

```text
############################################################
# File:          example.conf
# Path:          $HOME/projects/example.conf
# Created:       2025-12-01 17:45
# Last modified: 2025-12-01 17:45
############################################################
```

---

## Installation

### Using Vim’s built-in `pack` mechanism (no plugin manager)

Clone the repository into your `pack` directory.

**Vim:**

```bash
mkdir -p ~/.vim/pack/mystuff/start
cd ~/.vim/pack/mystuff/start
git clone git@github.com:hasmaneuroda/vim-file-header.git
```

**Neovim:**

```bash
mkdir -p ~/.config/nvim/pack/mystuff/start
cd ~/.config/nvim/pack/mystuff/start
git clone git@github.com:hasmaneuroda/vim-file-header.git
```

On the next start, Vim/Neovim will automatically load `plugin/file_header.vim`.

### Using a plugin manager (example: vim-plug)

```vim
call plug#begin('~/.vim/plugged')

Plug 'hasmaneuroda/vim-file-header'

call plug#end()
```

Then run `:PlugInstall`.

---

## Configuration

By default, the plugin activates for:

```text
*.sh,*.conf,*.service,*.timer
```

You can override this list in your `vimrc` **before** the plugin is loaded:

```vim
" Example: add Python files and drop .timer
let g:file_header_patterns = '*.sh,*.conf,*.service,*.py'
```

This affects:

- When headers are automatically inserted (`BufNewFile`)
- When `Last modified` is automatically updated (`BufWritePre`)

---

## Usage

### Automatic behaviour

- When you create a **new file** matching `g:file_header_patterns`, the plugin:
  - Inserts a header at the top of the file
  - For `*.sh`:
    - Adds a shebang if it does not exist
    - Places the header below the shebang if it does exist

- Whenever you **write** a matching file, the plugin:
  - Searches for a `# Last modified:` line in the header
  - Updates it with the current timestamp

The plugin will **not** insert a second header if one already exists.  
It checks the first lines for a `# File:` header marker.

### Adding a header to existing files

You can add a header manually to an existing file with:

```vim
:AddFileheader
```

For shell scripts:

- If a shebang exists, the header is inserted directly below it.
- If no shebang exists, the plugin inserts a shebang and then the header.

You can also define a convenient mapping in your `.vimrc`:

```vim
nnoremap <leader>fh :AddFileHeader<CR>
```

---

## Header format

The header is a simple comment block, framed by a `#` border.  
The border length and spacing are fixed in the plugin, but you can change them in `plugin/fileHeader.vim` if you want a different style:

- Border: `repeat('#', 60)`
- Comment prefix: `#`
- `$HOME` is used instead of an absolute `/home/username` prefix if the file is inside your home directory.

---

## Limitations and notes

- The plugin assumes `bash` as the shell for `*.sh`:
  - Shebang: `#!/usr/bin/env bash`
- Only lines beginning with `# Last modified:` are updated.  
  If you change that label, automatic updates will no longer work.
- The plugin is intentionally minimal and does not try to handle language-specific metadata (module docstrings, license headers, etc.).

---
