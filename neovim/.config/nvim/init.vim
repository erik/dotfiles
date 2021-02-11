set mouse=a

set shiftwidth=2
set expandtab
set smartcase

set showmatch

" Works better with light backgrounds
colorscheme slate

" Kill trailing spaces on save
autocmd BufWritePre * %s/\s\+$//e
