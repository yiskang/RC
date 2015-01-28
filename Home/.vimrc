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
Plugin 'Rip-Rip/clang_complete'

" Filetype
Plugin 'othree/html5.vim'
Plugin 'othree/xml.vim'

" Vim
Plugin 'othree/vim-syntax-enhanced'
Plugin 'slim-template/vim-slim'

" Improve
Plugin 'SyntaxComplete'

call vundle#end()            " required
filetype plugin indent on    " required


" //--------Seperation Line--------//


" !!Basic Setting!!
filetype on
filetype plugin on
filetype indent on
set nocompatible
set wrap
set showtabline=2 " always show tab line
set ruler
set nu
set nuw=5
set tabstop=6
set softtabstop=6
set shiftwidth=6
set expandtab
set autoindent
set smartindent
set cindent
set hlsearch

" Colorful VIM
colorscheme railscasts
syntax on
set t_Co=256
let g:solarized_termcolors=256
let g:solarized_termtrans=1
set background=dark

" Encoding
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,big5
set ambiwidth=double
language message zh_TW.UTF-8

" Filetype
" Omnifunc Setting
setlocal omnifunc=syntaxcomplete#Complete
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags noci
autocmd FileType css set omnifunc=csscomplete#CompleteCSS noci

" Special File Types
au BufRead,BufNewFile *.json set syntax=json
au BufRead,BufNewFile *.ctp set syntax=php


" //--------Seperation Line--------//


" !!Plugin Setting!!

" Autocomplpop - acp
let g:acp_enableAtStartup = 1
let g:acp_completeOption = '.,w,b,u,t,i,k'
let g:acp_behaviorSnipmateLength = 1
let g:acp_behaviorUserDefinedMeets = 'acp#meetsForKeyword'
let g:acp_behaviorUserDefinedFunction = 'syntaxcomplete#Complete'
let g:omni_syntax_use_iskeyword = 0

" Autocomplete - clang
let s:clang_library_path = '/Library/Developer/CommandLineTools/usr/lib'
if isdirectory(s:clang_library_path)
      let g:clang_library_path=s:clang_library_path
endif

" //--------Seperation Line--------//

