"
" vim-fileheader: lightweight header insertion + Last modified update
"
" - Inserts a header for selected new files (BufNewFile)
" - Provides :AddHeader to add a header manually
" - Updates the "Last modified" line on save (BufWritePre) when a header exists
"
" Notes:
"   * This plugin keeps changes minimal and avoids :substitute commands, so it does
"     not depend on "previous substitute pattern" state.
"   * Paths inside $HOME are shown as ~/… (no username in the header).
"

if exists('g:loaded_vim_fileheader')
  finish
endif
let g:loaded_vim_fileheader = 1

" -------------------------
" Autocommands and command
" -------------------------
if has('autocmd')
  augroup fileHeader_insert
    autocmd!
    " Add a header only for new files with the following extensions
    autocmd BufNewFile *.sh,*.conf,*.service,*.timer,*.info call s:InsertHeader()
  augroup END

  augroup fileHeader_last_modified
    autocmd!
    " Update the Last modified line before saving (only when a header exists)
    autocmd BufWritePre * call s:UpdateLastModified()
  augroup END
endif

" Add a header to the current buffer (also works for existing files).
command! -bar AddHeader call s:InsertHeader()

" -------------------------
" Helpers
" -------------------------
function! s:PrettyPath(path) abort
  " Replace the user's home directory prefix with "~" (hides the username).
  let l:home = expand('$HOME')
  if empty(a:path)
    return '[No Name]'
  endif

  " Exact home path
  if a:path ==# l:home
    return '~'
  endif

  " Home subpaths
  if stridx(a:path, l:home . '/') == 0
    return '~' . a:path[len(l:home):]
  endif

  return a:path
endfunction

function! s:HasHeader() abort
  " Detect our header by looking for '# File:' within the first few lines.
  let l:max = min([line('$'), 20])
  for lnum in range(1, l:max)
    if getline(lnum) =~# '^#\s\+File:\s'
      return 1
    endif
  endfor
  return 0
endfunction

function! s:FindLastModifiedLine() abort
  " Search only near the top; the header is expected to be there.
  let l:max = min([line('$'), 60])
  for lnum in range(1, l:max)
    if getline(lnum) =~# '^#\s\+Last modified:\s'
      return lnum
    endif
  endfor
  return 0
endfunction

" -------------------------
" Core functionality
" -------------------------
function! s:InsertHeader() abort
  " Prevent duplicate headers.
  if s:HasHeader()
    return
  endif

  let l:comment = '#'
  let l:date  = strftime('%Y-%m-%d %H:%M')
  let l:file  = expand('%:t')     " Filename only
  let l:path  = expand('%:p')     " Absolute path (may be empty for unnamed buffers)
  let l:ext   = expand('%:e')
  let l:path_display = s:PrettyPath(l:path)

  let l:border = repeat('#', 60)

  " Header block (without a shebang line).
  let l:header_lines = [
        \ l:border,
        \ l:comment . ' File:          ' . l:file,
        \ l:comment . ' Path:          ' . l:path_display,
        \ l:comment . ' Created:       ' . l:date,
        \ l:comment . ' Last modified: ' . l:date,
        \ l:border,
        \ ''
        \ ]

  " Special case: shell scripts.
  if l:ext ==# 'sh'
    let l:firstline = getline(1)

    " Case 1: a shebang already exists -> insert header after line 1.
    if l:firstline =~# '^#!'
      call append(1, l:header_lines)

    " Case 2: no shebang -> prepend shebang + header at the top.
    else
      let l:lines = ['#!/usr/bin/env bash', '']
      let l:lines += l:header_lines
      call append(0, l:lines)
    endif

  " All other file types: put the header at the very top.
  else
    call append(0, l:header_lines)
  endif

  " Ensure the Last modified line is correct immediately after insertion.
  call s:UpdateLastModified()

  " Place the cursor at the end of the file (below the header).
  normal! G
endfunction

function! s:UpdateLastModified() abort
  " Only update when the buffer is actually modified; avoid changing files on
  " no-op writes.
  if !&modified
    return
  endif

  " Only touch files that already have our header.
  if !s:HasHeader()
    return
  endif

  let l:lnum = s:FindLastModifiedLine()
  if l:lnum
    let l:date = strftime('%Y-%m-%d %H:%M')
    call setline(l:lnum, '# Last modified: ' . l:date)
  endif
endfunction
