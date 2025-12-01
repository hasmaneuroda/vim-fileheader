if has('autocmd')
  augroup my_file_header
    autocmd!
    " Add header only for *new* files with diesen Endungen
    autocmd BufNewFile *.sh,*.conf,*.service,*.timer,*.info call InsertHeader()
  augroup END

  augroup my_last_modified
    autocmd!
    " Update the Last modified line before saving
    autocmd BufWritePre *.sh,*.conf,*.service,*.timer,*.info call UpdateLastModified()
  augroup END
endif

function! InsertHeader()
  " Prevent duplicate headers: look for '# File:' in first 10 lines
  for lnum in range(1, 10)
    if getline(lnum) =~# '^# File:\s'
      return
    endif
  endfor

  let l:comment = '#'

  let l:date  = strftime('%Y-%m-%d %H:%M')
  let l:file  = expand('%:t')     " filename only
  let l:path  = expand('%:p')     " full path
  let l:home  = expand('$HOME')
  let l:ext   = expand('%:e')

  " Display $HOME/… instead of /home/user/…
  if l:path[:len(l:home)-1] ==# l:home
    let l:path_display = '$HOME' . l:path[len(l:home):]
  else
    let l:path_display = l:path
  endif

  let l:border = repeat('#', 60)

  " Headerblock (ohne Shebang)
  let l:header_lines = [
        \ l:border,
        \ l:comment . ' File:          ' . l:file,
        \ l:comment . ' Path:          ' . l:path_display,
        \ l:comment . ' Created:       ' . l:date,
        \ l:comment . ' Last modified: ' . l:date,
        \ l:border,
        \ ''
        \ ]

  " Sonderfall: Shellskript
  if l:ext ==# 'sh'
    let l:firstline = getline(1)

    " Fall 1: Shebang existiert bereits
    if l:firstline =~# '^#!'
      " Header nach der ersten Zeile einfügen
      call append(1, l:header_lines)

    " Fall 2: keine Shebang-Zeile, aber evtl. schon Inhalt
    else
      " Shebang + Header an den Anfang
      let l:lines = ['#!/usr/bin/env bash', '']
      let l:lines += l:header_lines
      call append(0, l:lines)
    endif

  " Alle anderen Dateitypen: Header ganz nach oben
  else
    call append(0, l:header_lines)
  endif

  " Cursor ans Ende (unterhalb des Headers)
  normal! G
endfunction

function! UpdateLastModified()
  let l:date = strftime('%Y-%m-%d %H:%M')
  " Find the 'Last modified' line in the header
  let l:lnum = search('^# Last modified:', 'nw')
  if l:lnum
    call setline(l:lnum, '# Last modified: ' . l:date)
  endif
endfunction

