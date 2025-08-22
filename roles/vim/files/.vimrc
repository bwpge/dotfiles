let mapleader = " "

" editor
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set nowrap

" searching
set ignorecase
set smartcase
set incsearch
set hlsearch

" proper backspace behavior
set backspace=indent,eol,start

" allow arrow keys to wrap lines
set whichwrap+=<,>,[,]

" window splits
set splitright
set splitbelow
set diffopt+=vertical

" keymaps
noremap <leader>q <cmd>confirm q<cr>
noremap <leader>w :w<cr>
noremap <leader>W :noa w<cr>
noremap <Tab> >>
noremap <S-tab> <<
inoremap <S-tab> <C-d>
xnoremap <Tab> >gv
xnoremap <S-tab> <gv
inoremap <M-BS> <C-w>
noremap + <C-a>
noremap - <C-x>
noremap <leader>e <cmd>Explore<cr>
noremap <leader>s= <C-w>=
noremap <S-Up> <C-w>+
noremap <S-Down> <C-w>-
noremap <S-Left> <C-w><
noremap <S-Right> <C-w>>
noremap <M-Left> <cmd>wincmd h<cr>
noremap <M-Right> <cmd>wincmd l<cr>
noremap <M-Up> <cmd>wincmd k<cr>
noremap <M-Down> <cmd>wincmd j<cr>
