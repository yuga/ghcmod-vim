let g:ghcmod_vim_ghcmodi_maxnum = 3

let s:ghcmodi_procs = []

function! ghcmod#iteract#send(message)
  let l:options = ghcmod#config#get_options()
  let cwd = getcwd()

  let l:num_procs = len(s:syntastic_haskell_ghc_modi_procs)

  for i in range(l:num_procs - 1, 0, -1)
    let l:proc_tmp = s:ghcmodi_procs[i]
    if l:proc_tmp.cwd == cwd
      if l:proc_tmp.is_valid
        let l:proc = l:proc_tmp
        let l:proc.last_access = localtime() "for debugging
      endif
      call remove(s:ghcmodi_procs, i)
      break
    endif
  endfor

  if !exists('l:proc')
    if l:num_procs >= g:ghcmod_vim_ghcmodi_maxnum
      let l:proc_old = s:ghcmodi_procs[0]
      call remove(s:syntastic_haskell_ghc_modi_procs, 0)
      call l:proc_old.stdin.close()
      call l:proc_old.waitpid()
    endif
    let cmds = [l:options['ghcmodi_cmd'], "-b", nr2char(11)]
    let l:proc = vimproc#popen3(cmds)
    call extend(l:proc, { 'cwd': cwd, 'last_access': localtime() })
  endif

  call l:proc.stdin.write(a:message . "\n")
  let l:res = l:proc.stdout.read_lines(100, 10000)
  let l:out = []

  if l:proc.stdout.eof
    let l:res = split(vimproc#system(l:options['ghcmodi_cmd']), "\n", 1)
  endif

  while (empty(l:res) || (l:res[-1] != 'OK' && l:res[-1] != 'NG')) && !l:proc.stdout.eof
    let l:out = l:proc.stdout.read_lines()
    let l:res += l:out
  endwhile

  if !empty(l:res) && l:res[-1] == 'OK'
    call add(s:ghcmodi_procs, l:proc)
  else
    call l:proc.kill(15)
    call l:proc.waitpid()
  endif

  return l:res
endfunction

function! ghcmod#iteract#clear()
  for proc in s:ghcmodi_procs
    call proc.kill(15)
    call proc.waitpid()
  endfor
  let s:ghcmodi_procs = []
endfunction

" vim: set ts=2 sw=2 et fdm=marker:
