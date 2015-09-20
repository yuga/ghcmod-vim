if !exists('g:ghcmod_vim_config_file_enabled')
    let g:ghcmod_vim_config_file_enabled = 0
endif

if !exists('g:ghcmod_vim_config_file')
    let g:ghcmod_vim_config_file = '.ghcmod_vim_config'
endif

let b:ghcmod_options = {}

function! s:LoadConfigFile()
  if filereadable(expand(g:ghcmod_vim_config_file))
    exe 'source ' . fnameescape(expand(g:ghcmod_vim_config_file))
  endif
endfunction

function! ghcmod#config#get_options()
  return b:ghcmod_options
endfunction

function! ghcmod#config#load_ghcmod_options()
  let l:options = { 'ghcmod_cmd': 'ghc-mod', 'ghcmodi_cmd': 'ghc-modi' }

  if g:ghcmod_vim_config_file_enabled
    call s:LoadConfigFile()
    if exists('g:ghc_mod_cmd')
        let l:options['ghcmod_cmd'] = g:ghc_mod_cmd
    endif
    if exists('g:ghc_modi_cmd')
        let l:options['ghcmodi_cmd'] = g:ghc_modi_cmd
    endif
  endif

  if !executable(l:options['ghcmod_cmd'])
      call ghcmod#util#print_error('ghcmod: ghc-mod is not executable!')
      remove(l:options, 'ghcmod_cmd')
  endif
  if !executable(l:options['ghcmodi_cmd'])
      call ghcmod#util#print_error('ghcmod: ghc-modi is not executable!')
      remove(l:options, 'ghcmodi_cmd')
  endif
    
  let b:ghcmod_options = l:options
  return l:options
endfunction

