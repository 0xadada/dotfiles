" make Vim more useful
set nocompatible

" Show the cursor position
set ruler
" set the visual mode selection to be exlusive rather than inclusive
set selection=exclusive

" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu

" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader from "\" (default) to comma
let mapleader=","
" Don’t add empty newlines at the end of files
set binary
set noeol

" Respect modeline in files
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
"
" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" Enable plugins
filetype plugin indent on

" code folding
set foldmethod=indent
set nofoldenable
set foldnestmax=10
set foldlevel=2

" Highlight current line
set nocursorline
" Highlight columns after 120 characters
let &colorcolumn=join(range(121,999),",")
" Make tabs as wide as four spaces
set tabstop=4
" Make shift indent operation add four spaces
set shiftwidth=4
" Convert tabs to spaces upon tabpress
set expandtab
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list
" Highlight searches
set hlsearch
" Highlight dynamically as pattern is typed
set incsearch
" Always show status line
set laststatus=2
" Enable mouse in all modes
set mouse=a
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Start scrolling three lines before the horizontal window border
set scrolloff=4

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")
  " Enable file type detection
  filetype on
endif

" HerringtonDarkholme/yats.vim
let g:yats_host_keyword=1 " yats should handle specfic keywords

" MaxMEllon/vim-jsx-pretty
let g:vim_jsx_pretty_disable_tsx=1 " let yats handle .tsx

" for hail2u/vim-css3-syntax
augroup VimCSS3Syntax
  autocmd!
  autocmd FileType css setlocal iskeyword+=-
augroup END

" vim-airline
let g:airline_detect_paste=1       " enable paste detection
set guifont=Source\ Code\ Pro\ for\ Powerline:h12
let g:airline_powerline_fonts=1
" vim-airline enable branch "fugitive" extension
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#branch#empty_message = ''
let g:airline#extensions#branch#displayed_head_limit = 10

" NERDTree
let g:NERDTreeIgnore = ['^dist$', '^node_modules$']

" vim-mix-format set to run Elixir formatter upon save
let g:mix_format_on_save = 1

" vim-pandoc-syntax
augroup pandoc_syntax
  au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END
