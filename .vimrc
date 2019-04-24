" Make Vim more useful
set nocompatible

" Plugins - Enable runtime path manipulation
execute pathogen#infect()

" set the color palette - Gruvbox
" old - " colors molokai
colorscheme gruvbox
set background=dark

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
" Change mapleader
let mapleader=","
" Don’t add empty newlines at the end of files
set binary
set noeol
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
    set undodir=~/.vim/undo
endif

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
" Highlight columns after 80 characters
let &colorcolumn=join(range(81,999),",")
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
" Ignore case of searches
set ignorecase
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
set scrolloff=3

" Strip trailing whitespace (,ss)
function! StripWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")
    " Enable file type detection
    filetype on
    " Treat .json files as .js
    autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
endif

" for vim-css3-syntax
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

" deoplete
let g:deoplete#enable_at_startup = 1
" Use tern for deoplete
let g:tern_request_timeout = 1
" let g:tern_show_signature_in_pum = '0'  " This do disable full signature type on autocomplete
"Add extra filetypes
let g:tern#filetypes = [
                \ 'jsx',
                \ 'vue']

" w0rp ale configuration
let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier']
let g:ale_fixers['scss'] = ['prettier']
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_use_local_config = 1

" vim-mix-format set to run Elixir formatter upon save
let g:mix_format_on_save = 1
