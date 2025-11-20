unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

let mapleader = " "
set notermguicolors

" use simple terminal colors
set notermguicolors

" enable different cursor shapes
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[1 q"
let &t_SR = "\<Esc>[4 q"

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
noremap <esc> <cmd>noh<cr><esc>
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
noremap <C-Up> <cmd>m-2<cr>
noremap <C-Down> <cmd>m+1<cr>
inoremap <C-Up> <esc><esc><cmd>m-2<cr>gi
inoremap <C-Down> <esc><esc><cmd>m+<cr>gi
noremap <C-d> m`"zyy"zpqzq``j
inoremap <C-d> <esc><esc>"zyy"zpqzqgi<C-o>j
xnoremap <C-d> "zy"zPqzqgv

" use system clipboard
if executable('xclip')
    function! XclipCopyV() range
        execute a:firstline . "," . a:lastline . "w !xclip -selection clipboard"
    endfunction
    vnoremap <leader>y :silent call XclipCopyV()<cr>
endif

" show highlights like neovim :Inspect
function! Inspect()
    for i1 in synstack(line("."), col("."))
        let i2 = synIDtrans(i1)
        let n1 = synIDattr(i1, "name")
        let n2 = synIDattr(i2, "name")
        echo n1 "->" n2
    endfor
endfunction
noremap <leader>I :call Inspect()<CR>

" colors
hi LineNr          ctermfg=8  ctermbg=0
hi CursorLineNr    ctermfg=11 ctermbg=0 cterm=bold
hi VertSplit       ctermfg=8  ctermbg=0
hi StatusLine      ctermfg=7  ctermbg=8
hi StatusLineNC    ctermfg=8  ctermbg=0

hi clear Visual
hi Visual          cterm=reverse ctermfg=0
hi Search          cterm=bold ctermfg=0 ctermbg=11
hi IncSearch       cterm=bold ctermfg=0 ctermbg=3
hi MatchParen      cterm=bold ctermfg=11 ctermbg=0

hi Comment         ctermfg=8  cterm=italic
hi Constant        ctermfg=13
hi String          ctermfg=2
hi Character       ctermfg=2
hi Number          ctermfg=3
hi Boolean         ctermfg=3
hi Float           ctermfg=3

hi Identifier      ctermfg=12
hi Function        ctermfg=12 cterm=bold

hi Statement       ctermfg=5
hi Conditional     ctermfg=5
hi Repeat          ctermfg=5
hi Label           ctermfg=5
hi Operator        ctermfg=6
hi Keyword         ctermfg=13 cterm=bold
hi Exception       ctermfg=1

hi PreProc         ctermfg=13
hi Include         ctermfg=13
hi Define          ctermfg=13
hi Macro           ctermfg=13
hi PreCondit       ctermfg=13

hi Type            ctermfg=11
hi StorageClass    ctermfg=11
hi Structure       ctermfg=11
hi Typedef         ctermfg=11

hi Special         ctermfg=14
hi SpecialKey      ctermfg=14
hi Tag             ctermfg=13
hi Delimiter       ctermfg=7
hi SpecialComment  ctermfg=8

hi Error           ctermfg=1  ctermbg=0 cterm=bold
hi Todo            ctermfg=11 ctermbg=0 cterm=bold
