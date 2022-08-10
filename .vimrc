set nocompatible              " be iMproved, required
filetype off                  " required

" Enable completion where available.
" This setting must be set before ALE is loaded.
let g:ale_completion_enabled = 1

"Vundle plugin declarations {{{
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"my plugins go here
Plugin 'preservim/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-fugitive'
Plugin 'dense-analysis/ale'
Plugin 'mattn/emmet-vim'
Plugin 'puremourning/vimspector'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'tmhedberg/SimpylFold'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-commentary'
Plugin 'Yggdroot/indentLine'
Plugin 'ryanoasis/vim-devicons'
Plugin 'habamax/vim-sendtoterm'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" }}}

" key mappings {{{
let mapleader=" "
nnoremap <C-s> :w<cr>
inoremap <C-s> <esc>:w<cr>a
nnoremap <up> :<up>

" functions for switching buffers that avoid switching to the integrated
" terminal if you have it open
function! NextBuffer()
        let all_buffers = range(bufnr(), bufnr("$"))
        for i in all_buffers
                if buflisted(i) && i != bufnr() && getbufvar(i, "&buftype") != "terminal"
                        execute i .. "b"
                        return
                endif
        endfor
        for j in range(1, bufnr())
                if buflisted(j) && j != bufnr() && getbufvar(j, "&buftype") != "terminal"
                        execute j .. "b"
                        return
                else
                        echo "no buffer to switch too"
                endif
        endfor
endfunction

function KillBuffer()
        let buftp = getbufvar(bufnr(), "&buftype")
        if len(getbufinfo({'buflisted':1})) == 1
                execute "q"
        elseif buftp == "help" || buftp == "nofile"
                execute "close"
        else
                execute "call NextBuffer()\|"..bufnr().."bd"
        endif
endfunction

function! OpenTerm()
        for i in range(1, bufnr("$"))
                if getbufvar(i, "&buftype") == "terminal"
                        let bufinfo = getbufinfo(i)
                        if get(bufinfo, 'hidden').hidden == 1
                                execute i .. "sb"
                                execute "res 10"
                                return
                        else
                                execute "wincmd j"
                        endif
                        return
                endif
        endfor
        execute "term"
endfunction

nnoremap <C-n> :call NextBuffer()<cr>
nnoremap <C-q> :call KillBuffer()<cr>
tmap <C-q> <C-w>:q<cr>
nnoremap <leader>l :noh<cr>
nnoremap <leader>t :call OpenTerm()<cr>
nnoremap <leader>db :VimspectorBreakpoints<cr>
nnoremap <C-F5> :VimspectorReset<cr>
nnoremap <leader>o :NERDTreeFocus<cr>
nnoremap <C-o> :NERDTreeToggle<cr>
nnoremap <leader>h :ALEHover<cr>
nnoremap <F2> :ALERename<cr>

" easier split navigation
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>
"}}}

"colorscheme config {{{
" applies dark background from 6pm till 8am
colorscheme solarized
if strftime("%H") > 17 || strftime("%H") < 8
        set background=dark
else
        set background=light
endif
" }}}

"Plugin Configurations {{{
"Vim Airline config
let g:airline#extensions#tabline#enabled = 1 " Enable the list of buffers

"YCM config
let g:ycm_autoclose_preview_window_after_completion=1

"NERDTree config
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
                                \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

"Vimspector config
let g:vimspector_enable_mappings='HUMAN'

"ALE config"
set omnifunc=ale#completion#OmniFunc
let g:ale_sign_column_always = 1
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_r_lintr_options="linters_with_defaults()"

" refer to ALE documentation for installation of below linters/fixers
let g:ale_linters = {
\   'vim': ['vimls'],
\   'python': ['pylsp', 'cspell'],
\   'html': ['vscodehtml', 'cspell'],
\   'css': ['vscodecss'],
\   'json': ['vscodejson'],
\   'text': ['proselint', 'cspell'],
\   'r': ['languageserver', 'lintr']
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['autopep8', 'trim_whitespace'],
\   'r': ['styler', 'remove_trailing_lines'],
\   'html': ['prettier', 'remove_trailing_lines', 'trim_whitespace'],
\   'css': ['prettier'],
\   'javascript': ['prettier'],
\   'json': ['prettier']
\}
" }}}

"python venv activation {{{
" if vim was launched from an active python venv, use it
python3 << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate')
  open(activate_this)
EOF
" }}}

"standard vim options {{{
set mouse=a "allow mouse input wherever possible
set termwinsize=10x0 "set the initial size of new terminal windows to 10 rows
set cursorline "highlight the current row
set updatetime=100 "reduced the updatetime for improved responsiveness
set confirm "confirm saving instead of failing action
set splitbelow "new splits go on the bottom
set splitright "new splits go on the right
set hidden "allow closing buffer without saving
set number "show line numbers
set encoding=utf-8
set foldcolumn=1
set ruler "always show cursor position
set hlsearch "highlight all search results
execute "noh"
set incsearch "incremental searching
set wildmenu "show vim cmd suggestions when i press tab
set showcmd "show partial commands
set ignorecase "ignore case when searching
set smartcase "dont ignore explicit uppercase
set nowrap "dont wrap lines
set fileformat=unix
set expandtab "convert tabs to spaces
set autoindent
set smarttab
" }}}

"filetype options {{{
augroup web_files
  autocmd!
  autocmd BufNewFile,BufRead *.html,*.css,*.js setlocal shiftwidth=2
  autocmd BufNewFile,BufRead *.html,*.css,*.js setlocal softtabstop=2
augroup END

augroup py_files
  autocmd!
  autocmd BufNewFile,BufRead *.py setlocal shiftwidth=4
  autocmd BufNewFile,BufRead *.py setlocal softtabstop=4
  autocmd BufNewFile,BufRead *.py nnoremap <buffer> <leader>t :terminal<cr>python3<cr><C-w>k
  autocmd BufNewFile,BufRead *.py nmap <buffer> <leader>r <Plug>(SendToTermLine)
  autocmd BufNewFile,BufRead *.py vmap <buffer> <leader>r <Plug>(SendToTerm)
  autocmd BufNewFile,BufRead *.py <buffer> <leader>r <Plug>(SendToTermLine)
  autocmd BufNewFile,BufRead *.py <buffer> <leader>r <Plug>(SendToTerm)
augroup END

augroup r_files
        autocmd!
        autocmd BufNewFile,BufRead *.r setlocal shiftwidth=4
        autocmd BufNewFile,BufRead *.r setlocal softtabstop=4
        autocmd BufNewFile,BufRead *.r inoremap <buffer> <leader>- <space><-<space>
        autocmd BufNewFile,BufRead *.r nnoremap <buffer> <leader>t :terminal<cr>R<cr><C-w>k
        autocmd BufNewFile,BufRead *.r nmap <buffer> <leader>r <Plug>(SendToTermLine)
        autocmd BufNewFile,BufRead *.r vmap <buffer> <leader>r <Plug>(SendToTerm)
augroup END

augroup vim_files
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}
