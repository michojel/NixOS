colorscheme PaperColor

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

" This maps non-breakable space to normal space
inoremap   <Space>
" Toggle paste with \p
nmap <leader>i :set invpaste<CR>

" allow for per-project settings
set secure
if getcwd() =~# '^/home/miminar/wsp/\(rh\|my\)/'
  set exrc
  set nosecure
endif
set scrolloff=5
set colorcolumn=+1,+2     " highlight line, that goes over textwidth

set ignorecase
set smartcase

lua <<EOF
require('nu').setup{}
EOF
