unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

let mapleader = " "
let g:netrw_banner = 0
set termguicolors
set cursorline
set number
set numberwidth=5

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
execute 'set fillchars+=eob:\ '

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
nnoremap <C-l> :nohlsearch<CR><C-l>
nnoremap Y y$
nnoremap x "_x
vnoremap x "_x
nnoremap <leader>q <cmd>confirm q<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>W :noa w<cr>
nnoremap <Tab> >>
nnoremap <S-tab> <<
inoremap <S-tab> <C-d>
xnoremap <Tab> >gv
xnoremap <S-tab> <gv
inoremap <M-BS> <C-w>
nnoremap + <C-a>
nnoremap - <C-x>
nnoremap <leader>s= <C-w>=
nnoremap <S-Up> <C-w>+
nnoremap <S-Down> <C-w>-
nnoremap <S-Left> <C-w><
nnoremap <S-Right> <C-w>>
nnoremap <M-Left> <cmd>wincmd h<cr>
nnoremap <M-Right> <cmd>wincmd l<cr>
nnoremap <M-Up> <cmd>wincmd k<cr>
nnoremap <M-Down> <cmd>wincmd j<cr>
nnoremap <C-Up> <cmd>m-2<cr>
nnoremap <C-Down> <cmd>m+1<cr>
inoremap <C-Up> <esc><esc><cmd>m-2<cr>gi
inoremap <C-Down> <esc><esc><cmd>m+<cr>gi
nnoremap <C-d> m`"zyy"zpqzq``j
inoremap <C-d> <esc><esc>"zyy"zpqzqgi<C-o>j
xnoremap <C-d> "zy"zPqzqgv
nnoremap <silent> <leader>n :set number!<CR>

" toggle netrw sidebar
function! ToggleNetrw()
    for w in range(1, winnr('$'))
        if getbufvar(winbufnr(w), '&filetype') ==# 'netrw'
            execute w . 'wincmd c'
            return
        endif
    endfor
    execute 'topleft vertical 40split'
    execute 'Explore'
endfunction
nnoremap <silent> <leader>e :call ToggleNetrw()<CR>

" use system clipboard
if executable('xclip')
    function! XclipCopy() range
        call system('xclip -in -selection clipboard', @")
    endfunction
    nnoremap <silent> <leader>y yy:call XclipCopy()<cr>
    vnoremap <silent> <leader>y y:call XclipCopy()<cr>
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
nnoremap <leader>I :call Inspect()<CR>

" highlight yanked text
augroup highlightYankedText
    autocmd!
    autocmd TextYankPost * call FlashYankedText()
augroup END
function! FlashYankedText()
    if &filetype ==# 'netrw'
        return
    endif
    if (!exists('g:yankedTextMatches'))
        let g:yankedTextMatches = []
    endif
    let matchId = matchadd('IncSearch', ".\\%>'\\[\\_.*\\%<']..")
    let windowId = winnr()
    call add(g:yankedTextMatches, [windowId, matchId])
    call timer_start(200, 'DeleteTemporaryMatch')
endfunction
function! DeleteTemporaryMatch(timerId)
    while !empty(g:yankedTextMatches)
        let match = remove(g:yankedTextMatches, 0)
        let windowID = match[0]
        let matchID = match[1]
        try
            call matchdelete(matchID, windowID)
        endtry
    endwhile
endfunction

" close non-essential buffers with 'q'
function! CloseNonEssential() abort
    if &buftype ==# 'quickfix'
        cclose
        return
    endif
    if getwininfo(win_getid())[0].loclist == 1
        lclose
        return
    endif

    quit
endfunction
au FileType help,qf,man,fugitive,netrw nnoremap <buffer> <nowait> <silent> q :call CloseNonEssential()<CR>

" colorscheme, based on catppuccin/vim
set background=dark
hi clear
if exists('syntax on')
    syntax reset
endif
let g:colors_name='neotechbase'
set t_Co=256

let s:rosewater = "#fccfd4"
let s:flamingo = "#fab8c0"
let s:pink = "#d5b7fa"
let s:mauve = "#b17af5"
let s:red = "#f73e53"
let s:maroon = "#f7a1ab"
let s:peach = "#eaa071"
let s:yellow = "#e5c07b"
let s:green = "#5dcd9a"
let s:teal = "#74baa8"
let s:sky = "#6dbee3"
let s:sapphire = "#7dc4e4"
let s:blue = "#748bdf"
let s:lavender = "#a9b9ef"

let s:text = "#ccd5e5"
let s:subtext1 = "#bcc5d4"
let s:subtext0 = "#aab2bf"
let s:overlay2 = "#6a7096"
let s:overlay1 = "#6a7096"
let s:overlay0 = "#6a7096"
let s:surface2 = "#363848"
let s:surface1 = "#363848"
let s:surface0 = "#2c2e3b"

let s:base = "#191d23"
let s:mantle = "#13171b"
let s:crust = "#0a0d0f"

function! s:hi(group, guisp, guifg, guibg, gui, cterm)
  let cmd = ""
  if a:guisp != ""
    let cmd = cmd . " guisp=" . a:guisp
  endif
  if a:guifg != ""
    let cmd = cmd . " guifg=" . a:guifg
  endif
  if a:guibg != ""
    let cmd = cmd . " guibg=" . a:guibg
  endif
  if a:gui != ""
    let cmd = cmd . " gui=" . a:gui
  endif
  if a:cterm != ""
    let cmd = cmd . " cterm=" . a:cterm
  endif
  if cmd != ""
    exec "hi " . a:group . cmd
  endif
endfunction

call s:hi("Normal", "NONE", s:text, s:base, "NONE", "NONE")
call s:hi("Visual", "NONE", "NONE", s:surface1,"bold", "bold")
call s:hi("Conceal", "NONE", s:overlay1, "NONE", "NONE", "NONE")
call s:hi("ColorColumn", "NONE", "NONE", s:surface0, "NONE", "NONE")
call s:hi("Cursor", "NONE", s:base, s:rosewater, "NONE", "NONE")
call s:hi("lCursor", "NONE", s:base, s:rosewater, "NONE", "NONE")
call s:hi("CursorIM", "NONE", s:base, s:rosewater, "NONE", "NONE")
call s:hi("CursorColumn", "NONE", "NONE", s:mantle, "NONE", "NONE")
call s:hi("CursorLine", "NONE", "NONE", s:surface0, "NONE", "NONE")
call s:hi("Directory", "NONE", s:blue, "NONE", "NONE", "NONE")
call s:hi("DiffAdd", "NONE", s:base, s:green, "NONE", "NONE")
call s:hi("DiffChange", "NONE", s:base, s:yellow, "NONE", "NONE")
call s:hi("DiffDelete", "NONE", s:base, s:red, "NONE", "NONE")
call s:hi("DiffText", "NONE", s:base, s:blue, "NONE", "NONE")
call s:hi("EndOfBuffer", "NONE", "NONE", "NONE", "NONE", "NONE")
call s:hi("ErrorMsg", "NONE", s:red, "NONE", "bolditalic"    , "bold,italic")
call s:hi("VertSplit", "NONE", s:crust, "NONE", "NONE", "NONE")
call s:hi("Folded", "NONE", s:blue, s:surface1, "NONE", "NONE")
call s:hi("FoldColumn", "NONE", s:overlay0, s:base, "NONE", "NONE")
call s:hi("SignColumn", "NONE", s:surface1, s:base, "NONE", "NONE")
call s:hi("CursorLineNR", "NONE", s:lavender, "NONE", "NONE", "NONE")
call s:hi("LineNr", "NONE", s:surface1, "NONE", "NONE", "NONE")
call s:hi("MatchParen", "NONE", s:peach, "NONE", "bold", "bold")
call s:hi("ModeMsg", "NONE", s:text, "NONE", "bold", "bold")
call s:hi("MoreMsg", "NONE", s:blue, "NONE", "NONE", "NONE")
call s:hi("NonText", "NONE", s:overlay0, "NONE", "NONE", "NONE")
call s:hi("Pmenu", "NONE", s:overlay2, s:surface0, "NONE", "NONE")
call s:hi("PmenuSel", "NONE", s:text, s:surface1, "bold", "bold")
call s:hi("PmenuSbar", "NONE", "NONE", s:surface1, "NONE", "NONE")
call s:hi("PmenuThumb", "NONE", "NONE", s:overlay0, "NONE", "NONE")
call s:hi("Question", "NONE", s:blue, "NONE", "NONE", "NONE")
call s:hi("QuickFixLine", "NONE", "NONE", s:surface1, "bold", "bold")
call s:hi("SpecialKey", "NONE", s:subtext0, "NONE", "NONE", "NONE")
call s:hi("SpellBad", "NONE", s:base, s:red, "NONE", "NONE")
call s:hi("SpellCap", "NONE", s:base, s:yellow, "NONE", "NONE")
call s:hi("SpellLocal", "NONE", s:base, s:blue, "NONE", "NONE")
call s:hi("SpellRare", "NONE", s:base, s:green, "NONE", "NONE")
call s:hi("StatusLine", "NONE", s:text, s:mantle, "NONE", "NONE")
call s:hi("StatusLineNC", "NONE", s:surface1, s:mantle, "NONE", "NONE")
call s:hi("StatusLineTerm", "NONE", s:text, s:mantle, "NONE", "NONE")
call s:hi("StatusLineTermNC", "NONE", s:surface1, s:mantle, "NONE", "NONE")
call s:hi("TabLine", "NONE", s:surface1, s:mantle, "NONE", "NONE")
call s:hi("TabLineFill", "NONE", "NONE", s:mantle, "NONE", "NONE")
call s:hi("TabLineSel", "NONE", s:green, s:surface1, "NONE", "NONE")
call s:hi("Title", "NONE", s:blue, "NONE", "bold", "bold")
call s:hi("VisualNOS", "NONE", "NONE", s:surface1, "bold", "bold")
call s:hi("WarningMsg", "NONE", s:yellow, "NONE", "NONE", "NONE")
call s:hi("WildMenu", "NONE", "NONE", s:overlay0, "NONE", "NONE")
call s:hi("Comment", "NONE", s:overlay0, "NONE", "italic", "italic")
call s:hi("Constant", "NONE", s:peach, "NONE", "NONE", "NONE")
call s:hi("Identifier", "NONE", s:text, "NONE", "NONE", "NONE")
call s:hi("Statement", "NONE", s:mauve, "NONE", "NONE", "NONE")
call s:hi("PreProc", "NONE", s:pink, "NONE", "NONE", "NONE")
call s:hi("Type", "NONE", s:yellow, "NONE", "NONE", "NONE")
call s:hi("Special", "NONE", s:pink, "NONE", "NONE", "NONE")
call s:hi("Underlined", "NONE", s:text, s:base, "underline", "underline")
call s:hi("Error", "NONE", s:red, "NONE", "NONE", "NONE")
call s:hi("Todo", "NONE", s:base, s:sky, "bold", "bold")
call s:hi("String", "NONE", s:green, "NONE", "NONE", "NONE")
call s:hi("Character", "NONE", s:teal, "NONE", "NONE", "NONE")
call s:hi("Number", "NONE", s:peach, "NONE", "NONE", "NONE")
call s:hi("Boolean", "NONE", s:peach, "NONE", "NONE", "NONE")
call s:hi("Float", "NONE", s:peach, "NONE", "NONE", "NONE")
call s:hi("Function", "NONE", s:blue, "NONE", "NONE", "NONE")
call s:hi("Conditional", "NONE", s:mauve, "NONE", "NONE", "NONE")
call s:hi("Repeat", "NONE", s:red, "NONE", "NONE", "NONE")
call s:hi("Label", "NONE", s:peach, "NONE", "NONE", "NONE")
call s:hi("Operator", "NONE", s:sky, "NONE", "NONE", "NONE")
call s:hi("Keyword", "NONE", s:mauve, "NONE", "NONE", "NONE")
call s:hi("Include", "NONE", s:mauve, "NONE", "NONE", "NONE")
call s:hi("StorageClass", "NONE", s:yellow, "NONE", "NONE", "NONE")
call s:hi("Structure", "NONE", s:yellow, "NONE", "NONE", "NONE")
call s:hi("Typedef", "NONE", s:yellow, "NONE", "NONE", "NONE")
call s:hi("debugPC", "NONE", "NONE", s:crust, "NONE", "NONE")
call s:hi("debugBreakpoint", "NONE", s:overlay0, s:base, "NONE", "NONE")
call s:hi("Delimiter", "NONE", s:overlay0, "NONE", "NONE", "NONE")
call s:hi("Search", "NONE", s:base, s:sky, "bold", "bold")
call s:hi("CurSearch", "NONE", s:base, s:red, "bold", "bold")
call s:hi("IncSearch", "NONE", s:base, s:sky, "bold", "bold")

hi link Define PreProc
hi link Macro PreProc
hi link PreCondit PreProc
hi link SpecialChar Special
hi link Tag Special
hi link SpecialComment Special
hi link Debug Special
hi link Exception Error
hi link StatusLineTerm StatusLine
hi link StatusLineTermNC StatusLineNC
hi link Terminal Normal
hi link Ignore Comment

let g:terminal_ansi_colors = [
  \ s:surface1, s:red, s:green, s:yellow, s:blue, s:pink, s:teal, s:subtext1,
  \ s:surface2, s:red, s:green, s:yellow, s:blue, s:pink, s:teal, s:subtext0
\ ]

" fancy statusline
set laststatus=2
set noshowmode
call s:hi("StatusLine", "NONE", s:text, s:mantle, "NONE", "NONE")
call s:hi("StatusModeNormal", "NONE", s:mantle, s:blue, "bold", "bold")
call s:hi("StatusModeInsert", "NONE", s:mantle, s:green, "bold", "bold")
call s:hi("StatusModeVisual", "NONE", s:mantle, s:mauve, "bold", "bold")
call s:hi("StatusModeVLine", "NONE", s:mantle, s:mauve, "bold", "bold")
call s:hi("StatusModeVBlock", "NONE", s:mantle, s:mauve, "bold", "bold")
call s:hi("StatusModeReplace", "NONE", s:mantle, s:sky, "bold", "bold")
call s:hi("StatusModeCommand", "NONE", s:mantle, s:peach, "bold", "bold")
call s:hi("StatusModeTerminal", "NONE", s:mantle, s:red, "bold", "bold")
call s:hi("StatusModeOther", "NONE", s:mantle, s:red, "bold", "bold")
call s:hi("StatusPos", "NONE", s:overlay0, s:mantle, "NONE", "NONE")
call s:hi("StatusFileChanged", "NONE", s:peach, s:mantle, "bold", "bold")
hi link StatusFile StatusLine
hi link StatusPos StatusLine

function! StatusModeText()
  let l:m = mode()
  return l:m ==# 'n'        ? 'NORMAL'  :
        \ l:m ==# 'i'       ? 'INSERT'  :
        \ l:m ==# 'v'       ? 'VISUAL'  :
        \ l:m ==# 'V'       ? 'V-LINE'  :
        \ l:m ==# "\<C-v>"  ? 'V-BLOCK' :
        \ l:m ==# 'R'       ? 'REPLACE' :
        \ l:m ==# 'c'       ? 'COMMAND' :
        \ l:m ==# 't'       ? 'TERMINAL' :
                            \ 'OTHER'
endfunction

function! StatusModeHL()
  let l:m = mode()
  return l:m ==# 'n'        ? 'StatusModeNormal'  :
        \ l:m ==# 'i'       ? 'StatusModeInsert'  :
        \ l:m ==# 'v'       ? 'StatusModeVisual'  :
        \ l:m ==# 'V'       ? 'StatusModeVLine'   :
        \ l:m ==# "\<C-v>"  ? 'StatusModeVBlock'  :
        \ l:m ==# 'R'       ? 'StatusModeReplace' :
        \ l:m ==# 'c'       ? 'StatusModeCommand' :
        \ l:m ==# 't'       ? 'StatusModeTerminal' :
                            \ 'StatusModeOther'
endfunction

function! StatusFileHL()
  return &modified ? '%#StatusFileChanged#' : '%#StatusFile#'
endfunction

set statusline=%{%'%#'.StatusModeHL().'#'%}\ %{StatusModeText()}\ %{%StatusFileHL()%}\ %f%#StatusLine#%=%#StatusPos#\ %l:%c\ %#
