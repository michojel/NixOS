if has('mouse')
  set mouse=a
endif

if has('syntax')
  " higlight current line (tip 1279)
  set cursorline
  highlight CursorLine term=none cterm=none ctermbg=235
  " TODO: find out what this does
  nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
endif

set tabstop=4      " number of columns occupied by a tab 
set softtabstop=4  " see multiple spaces as tabstops so <BS> does the right thing
set expandtab      " converts tabs to white space
set shiftwidth=4   " width for autoindents
set autoindent     " indent a new line the same amount as the line just typed
set number         " add line numbers
set cc=110         " set an 80 column border for good coding style

" This maps non-breakable space to normal space
inoremap   <Space>
" Toggle paste with \p
nmap <leader>i :set invpaste<CR>

" allow for per-project settings
set secure
if getcwd() =~# '^/home/\(miminar\|michojel\)/wsp/\(rh\|my\|ondat\|ethz\)/'
  set exrc
  set nosecure
endif
set scrolloff=5
set colorcolumn=+1,+2     " highlight line, that goes over textwidth

set ignorecase
set smartcase

set diffopt+=vertical                                                                                                                                              
if !exists(":DiffOrig")
  command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_
    \ | diffthis | wincmd p | diffthis
endif

augroup vim_md_ale
  autocmd!
  autocmd FileType markdown set et ts=4 sw=4
augroup END
