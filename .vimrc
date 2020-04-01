set switchbuf-=newtab
set hlsearch
hi Search ctermbg=White ctermfg=Black
nnoremap <Space> :noh<CR>
let g:ale_linters = {'python': ['pylint'],
      \ 'yaml' : ['cloudformation']}
" set nocompatible
set number
" filetype plugin on
filetype plugin indent on
syntax on 
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
autocmd ColorScheme dracula highlight link VimwikiListTodo DraculaCyan
      \ | highlight link VimwikiList DraculaCyan
      \ | highlight link VimwikiLink DraculaLink
colorscheme dracula
" autocmd FileType calendar nmap <buffer> <CR> :<C-u>call vimwiki#diary#calendar_action(b:calendar.day().get_day(), b:calendar.day().get_month(), b:calendar.day().get_year(), b:calendar.day().week(), "V")<CR>
"autocmd BufEnter * if &modifiable | NERDTreeFind | wincmd p | endif
" returns true iff is NERDTree open/active
" function! rc:isNTOpen()        
"   return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
" endfunction

" " calls NERDTreeFind iff NERDTree is active, current window contains a modifiable file, and we're not in vimdiff
" function! rc:syncTree()
"   if &modifiable && rc:isNTOpen() && strlen(expand('%')) > 0 && !&diff
"     NERDTreeFind
"     wincmd p
"   endif
" endfunction

" autocmd BufEnter * call rc:syncTree()
if executable('ag')
  let g:ackprg = 'rg --vimgrep --hidden'
endif
cnoreabbrev Ack Ack!
nnoremap <Leader>g :RG<Space>
vnoremap gv :<C-U>call SearchWordWithRg()<CR>
function! SearchWordWithRg()
  execute 'RG' expand('<cword>')
endfunction
let g:clj_fmt_autosave = 0
let g:clojure_maxlines = 200
let g:clojure_align_multiline_strings = 1
let g:clojure_fuzzy_indent = 1
set completeopt+=preview
" If you prefer the Omni-Completion tip window to close when a selection is
" " made, these lines close it on movement in insert mode or when leaving
" " insert mode
" autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
" autocmd InsertLeave * if pumvisible() == 0|pclose|endif
autocmd CompleteDone * pclose
let g:ctrlp_show_hidden = 1
" Reveal tab characters cause they are a pain
set list
set listchars=tab:>-

nnoremap <Leader>ud :w !diff % -<CR>
" clojure macros
nnoremap <Leader>rt v% :'<,'>RunTests<CR>
nnoremap <Leader>so :syntax on<CR>
nnoremap tl<Space> :VimwikiToggleListItem<CR>

let g:ctrlp_custom_ignore = 'target\|task-history'
let g:rainbow_active = 1
set autoread

" Read the created file and echo it
" if findfile("service/.nrepl-port", ".") == "SpecificFile"
" let s:lines = readfile('service/.nrepl-port')
" for s:line in s:lines
"   let nreplport = echo s:line
"   :FireplaceConnect 'localhost:' .l:nreplport
" endfor
" endif
" fzf mapping
let $FZF_DEFAULT_COMMAND = 'RG --hidden --ignore .git -l -g ""'
" Better command history with q:
command! CmdHist call fzf#vim#command_history({'right': '40'})
nnoremap q: :CmdHist<CR>

" Better search history
command! QHist call fzf#vim#search_history({'right': '40'})
nnoremap q/ :QHist<CR>

command! -bang -nargs=* -complete=dir BLines 
      \ call fzf#vim#buffer_lines(<q-args>, fzf#vim#with_preview({"placeholder": "{2}:{3}" ,'options': ['--layout=reverse', '--info=inline', '--bind=shift-left:preview-page-up,shift-right:preview-page-down']}), <bang>0)

command! -bang -nargs=* -complete=dir Buffers
      \ call fzf#vim#buffers(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline', '--bind=shift-left:preview-page-up,shift-right:preview-page-down']}), <bang>0)

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --hidden --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
" command! -bang -nargs=+ -complete=dir Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
" command! -bang -nargs=* Ag
"     \ call fzf#vim#ag(
" \   '<q-args>',
" \   <bang>0 ? fzf#vim#with_preview('up:60%')
" \           : fzf#vim#with_preview('right:50%:hidden', '?'),
" \   <bang>0)

let g:fzf_preview_command = 'bat --color=always --style=grid {-1}'
nnoremap <silent> <leader>a :FzfPreviewBuffers<CR>
nnoremap <silent> <leader>A :Windows<CR>
nnoremap <silent> <leader>; :BLines<CR>
nnoremap <silent> <leader>' :FzfPreviewLines<CR>
nnoremap <silent> <leader>o :BTags<CR>
nnoremap <silent> <leader>O :Tags<CR>

nnoremap <silent> <leader>f :call Fzf_dev()<CR>

" ripgrep
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

" Files + devicons
set encoding=utf8
set guifont=:h
set guifont=DroidSansMono\ Nerd\ Font:h11
" set guifont=Hack_Nerd_Font:h11

function! Fzf_dev()
" Files + devicons + floating fzf
  let l:fzf_files_options = '--preview "bat --theme="OneHalfDark" --style=numbers,changes --color always {3..-1} | head -200" --expect=ctrl-v,ctrl-x'
  let s:files_status = {}

  function! s:cacheGitStatus()
    let l:gitcmd = 'git -c color.status=false -C ' . $PWD . ' status -s'
    let l:statusesStr = system(l:gitcmd)
    let l:statusesSplit = split(l:statusesStr, '\n')
    for l:statusLine in l:statusesSplit
      let l:fileStatus = split(l:statusLine, ' ')[0]
      let l:fileName = split(l:statusLine, ' ')[1]
      let s:files_status[l:fileName] = l:fileStatus
    endfor
  endfunction

  function! s:files()
    call s:cacheGitStatus()
    let l:files = split(system($FZF_DEFAULT_COMMAND), '\n')
    return s:prepend_indicators(l:files)
  endfunction

  function! s:prepend_indicators(candidates)
    return s:prepend_git_status(s:prepend_icon(a:candidates))
  endfunction

  function! s:prepend_git_status(candidates)
    let l:result = []
    for l:candidate in a:candidates
      let l:status = ''
      let l:icon = split(l:candidate, ' ')[0]
      let l:filePathWithIcon = split(l:candidate, ' ')[1]

      let l:pos = strridx(l:filePathWithIcon, ' ')
      let l:file_path = l:filePathWithIcon[pos+1:-1]
      if has_key(s:files_status, l:file_path)
        let l:status = s:files_status[l:file_path]
        call add(l:result, printf('%s %s %s', l:status, l:icon, l:file_path))
      else
        " printf statement contains a load-bearing unicode space
        " the file path is extracted from the list item using {3..-1},
        " this breaks if there is a different number of spaces, which
        " means if we add a space in the following printf it breaks.
        " using a unicode space preserves the spacing in the fzf list
        " without breaking the {3..-1} index
        call add(l:result, printf('%s %s %s', ' ', l:icon, l:file_path))
      endif
    endfor

    return l:result
  endfunction

  function! s:prepend_icon(candidates)
    let l:result = []
    for l:candidate in a:candidates
      let l:filename = fnamemodify(l:candidate, ':p:t')
      let l:icon = WebDevIconsGetFileTypeSymbol(l:filename, isdirectory(l:filename))
      call add(l:result, printf('%s %s', l:icon, l:candidate))
    endfor

    return l:result
  endfunction

  function! s:edit_file(lines)
    if len(a:lines) < 2 | return | endif

    let l:cmd = get({'ctrl-x': 'split',
                 \ 'ctrl-v': 'vertical split',
                 \ 'ctrl-t': 'tabe'}, a:lines[0], 'e')

    for l:item in a:lines[1:]
      let l:pos = strridx(l:item, ' ')
      let l:file_path = l:item[pos+1:-1]
      execute 'silent '. l:cmd . ' ' . l:file_path
    endfor
  endfunction

  call fzf#run({
        \ 'source': <sid>files(),
        \ 'sink*':   function('s:edit_file'),
        \ 'options': '-m --preview-window=right:70%:noborder --prompt Files\> ' . l:fzf_files_options,
        \ 'down':    '40%'})
endfunction

nmap <Leader>p <Plug>yankstack_substitute_older_paste
nmap <Leader>n <Plug>yankstack_substitute_newer_paste
