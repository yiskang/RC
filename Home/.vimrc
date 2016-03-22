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
Plugin 'myhere/vim-nodejs-complete'
Plugin 'marijnh/tern_for_vim'

" JavaScript
Plugin 'othree/yajs.vim'
Plugin 'JSON.vim'
Plugin 'elzr/vim-json'
Plugin 'othree/javascript-libraries-syntax.vim'
Plugin 'jiangmiao/simple-javascript-indenter'
Plugin 'othree/jspc.vim'
Plugin 'bigfish/vim-js-context-coloring'
Plugin 'heavenshell/vim-jsdoc'
Plugin 'othree/jsdoc-syntax.vim'

" Filetype
Plugin 'othree/html5.vim'
Plugin 'othree/xml.vim'

Plugin 'SyntaxRange'

Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'

Plugin 'keith/swift.vim'

" CSS, SCSS
Plugin 'hail2u/vim-css3-syntax'
Plugin 'ap/vim-css-color'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'csscomb/vim-csscomb'
Plugin 'othree/csscomplete.vim'

" Vim
Plugin 'othree/vim-syntax-enhanced'
Plugin 'slim-template/vim-slim'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Improve
Plugin 'SyntaxComplete'

" Documentation
Plugin 'rizzatti/dash.vim'

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
set tabstop=2
set softtabstop=2
set shiftwidth=2
set noexpandtab
set autoindent
set smartindent
set cindent
set hlsearch
set foldmethod=marker
set backspace=indent,eol,start whichwrap+=<,>,[,]
set hidden
set nobomb
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
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType scss set sw=2

let g:omni_syntax_group_include_javascript = 'javascript\w\+,jquery\w\+,underscore\w\+,prelude\w\+,requirejs\w\+'
let b:html_omni_flavor = 'html5'

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
let s:uname = system("echo -n \"$(uname)\"")
let s:clang_library_path = ''

" If uname is working, do path mapping
if !v:shell_error
      if s:uname == "Darwin"
            let s:clang_library_path = '/Library/Developer/CommandLineTools/usr/lib'
      elseif s:uname == "Linux"
            let s:clang_library_path = '/usr/include'
      endif
endif

if !empty(s:clang_library_path) && isdirectory(s:clang_library_path)
      let g:clang_library_path = s:clang_library_path
endif

" Syntax Range
autocmd FileType html call SyntaxRange#Include('/<script[^>]*>/', '</script>', 'javascript', 'htmlTagName')
autocmd FileType html call SyntaxRange#Include('/<style[^>]*>/', '</style>', 'css', 'htmlTagName')

" JavaScript Context Coloring
let g:js_context_colors_enabled = 0
let g:js_context_colors = [ "#EEEEEE", "#99FF99", "#ded35d", 172, "#ff9999", 161, 63 ]

" VIM JsDoc
autocmd FileType javascript nmap <silent> <C-l> ?function<cr>:noh<cr><Plug>(jsdoc)
"let g:jsdoc_allow_input_prompt = 1

" Airline
let g:airline_theme = 'solarized'
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" set status line
set laststatus=2

" jsx
let g:jsx_ext_required = 0

" Indent
let g:html_indent_inctags = "html,body,head,tbody,a"
let g:event_handler_attributes_complete = 0
let g:microdata_attributes_complete = 0
let g:SimpleJsIndenter_BriefMode = 1

" Tab Indent
nmap <tab> V>
vmap <tab> >gv
nmap <s-tab> V<
vmap <s-tab> <gv

" //--------Seperation Line--------//
