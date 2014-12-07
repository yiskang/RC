" Vimrc from Eason (yskang212310@gmail.com) 
" 2014-12

" !!Plugin Management!!
set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Popup Competition
Plugin 'L9'
Plugin 'othree/vim-autocomplpop'
Plugin 'MarcWeber/vim-addon-mw-utils.git'
Plugin 'tomtom/tlib_vim.git'
Plugin 'honza/vim-snippets'
Plugin 'garbas/vim-snipmate'

call vundle#end()            " required
filetype plugin indent on    " required


" //--------Seperation Line--------//


" !!Basic Setting!!
filetype on
filetype plugin on
filetype indent on
set nocompatible
set autoindent
set smartindent
set cindent

" Colorful VIM
colorscheme railscasts
syntax on
set t_Co=256

" Encoding
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,big5
set ambiwidth=double
language message zh_TW.UTF-8


" //--------Seperation Line--------//


" !!Plugin Setting!!

" Autocomplpop - acp
let g:acp_enableAtStartup = 1
let g:acp_behaviorSnipmateLength = 1
let g:acp_behaviorUserDefinedMeets = 'acp#meetsForKeyword'
let g:acp_behaviorUserDefinedFunction = 'syntaxcomplete#Complete'


" //--------Seperation Line--------//


