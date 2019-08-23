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

call vundle#end() "required
filetype plugin indent on "required


syntax on
colorscheme dracula
set number
set autoindent
set cc=80
set tabstop=4

filetype on
