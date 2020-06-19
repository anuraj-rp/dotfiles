set nocompatible	 "this turns off compatibility with venerable vi
filetype off		 "required by vundle

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" if Vundle should install plugins in a different directory then 
" call vundle#begin('~/some/path/here')

" let Vundle manage Vundle plugin. required
Plugin 'VundleVim/Vundle.vim'

" install the dracula colourscheme plugin
Plugin 'dracula/vim'
" install the solarized colorscheme plugin
Plugin 'altercation/vim-colors-solarized'
" install the onedark colorscheme plugin
Plugin 'joshdick/onedark.vim'
Plugin 'hdima/python-syntax' 
" install the YouCompleteMe plugin
Plugin 'Valloric/YouCompleteMe'


call vundle#end() "required
filetype plugin indent on "required


call togglebg#map("<F5>")

syntax enable
"set background=dark
"colorscheme dracula
colorscheme onedark 
set number
set autoindent
set cc=120
set tabstop=4

"split navigations key combinations
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"PEP 8 indendation for python files
au BufNewFile,BufRead *.py
	\ set tabstop=4 |
	\ set softtabstop=4 | 
	\ set shiftwidth=4 |
	\ set textwidth=120 |
	\ set expandtab |
	\ set autoindent |
	\ set fileformat=unix

"Flag unnecessary whitespace
au BufRead, BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

"Set utf-8 encoding for python files
au BufNewFile,BufRead *.py
	\ set encoding=utf-8

let python_highlight_all=1

filetype on

