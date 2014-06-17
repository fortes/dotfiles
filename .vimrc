" vim:fdm=marker ts=2 sts=2 sw=2 fdl=0

" NeoBundle Setup {{{
if has('vim_starting')
  set nocompatible
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'
" }}}

" Bundles {{{
" VimProc install / build
NeoBundle 'Shougo/vimproc.vim',{
\   'build' : {
\     'mac' : 'make -f make_mac.mak',
\     'unix' : 'make -f make_unix.mak',
\     'cygwin': 'make -f make_cygwin.mak',
\     'windows': '"C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\nmake.exe" make_msvc32.mak',
\   },
\ }
NeoBundle 'Shougo/vimshell.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neocomplcache.vim'
NeoBundle 'Shougo/neosnippet.vim'
" Languages & Dev Tools
NeoBundle 'marijnh/tern_for_vim',{
\   'build' : {
\     'others': 'npm install',
\   }
\ }
NeoBundle 'tpope/vim-fugitive'
" Colors / Display
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'nathanaelkane/vim-indent-guides'
" Gutter & Status Line
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'bling/vim-airline'
call neobundle#end()

" Complete loading
filetype plugin indent on
syntax enable

" Prompt to install missing bundles
NeoBundleCheck
" }}}

" Base Configuration {{{

" Turn off 'Thanks for flying Vim' message
if has('notitle')
  set notitle
else
  let &titleold=getcwd()
endif

" Hide default mode text (i.e. INSERT below status line)
set noshowmode

" Hide the intro screen
set shortmess+=I

" Default to UTF-8
set encoding=utf-8
set termencoding=utf-8
set fileformats+=mac

" Make filename tab completion more bash-like
set wildmenu
set wildmode=longest,full

" Pretty much always on a fast connection
set ttyfast

" Automatically reload modified files
set autoread

" Don't use modelines (security concerns)
set nomodeline

" Show cursor position in bottom right
set ruler

" Make the xterm window inherit Vim title
set title

" Don't use backup files, we have Dropbox/Git for that
set nobackup
set noswapfile

" Disable visual bell
set noerrorbells
set visualbell t_vb=

" Support mouse
set mouse=a
set ttymouse=xterm2

" Use comma as leader
let mapleader=","

" Make ; equivalent to : (faster commands)
nnoremap ; :

" Map jj and jk to <ESC> to leave insert mode quickly
inoremap jj <ESC>
inoremap jk <ESC>

" Make j/k move screen visible lines, not file lines
nnoremap j gj
nnoremap k gk

" Make h/l move across beginning/end of line
set whichwrap+=hl

" Remove silly restrictions from backspace
set backspace=indent,eol,start

" }}}

" Indents and Wrapping {{{
set autoindent

" Spaces, not tabs. Two characters
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
" Round up indents
set shiftround
set smarttab
set cindent

" Be smart when indenting
set smartindent

" Soft wrap, with indicator
set wrap
" Wrap at 80 characters
set textwidth=80
" Only break the line if wasn't longer than 80 chars when editing began
" and there is a blank somewhere in the line
set formatoptions+=lb
" Don't continue comments when pressing o/O
set formatoptions-=o
" Recognize numbered lists and wrap accordingly
set formatoptions+=n
" Remove comment leader when joining lines
set formatoptions+=j

" Some files shouldn't be wrapped automatically
autocmd BufRead,BufNewFile *.txt,*.md,*.markdown setlocal textwidth=0
" }}}

" Autocomplete {{{
" Consider '-' part of a world when tab completion, etc
set iskeyword+=-

" Be smart about case when using autocomplete
set infercase

" Enable Omnicomplete
set omnifunc=syntaxcomplete#Complete

" Neocomplcache
" Show matches automatically
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_max_list = 5
" Automatically select first option in list
let g:neocomplcache_enable_auto_select = 1
" Match across string like Control-P
let g:neocomplcache_enable_fuzzy_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
\   'default' : '',
\   'vimshell' : $HOME.'/.vimshell_hist'
\ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

if !exists('g:neocomplcache_same_filetype_lists')
  let g:neocomplcache_same_filetype_lists = {}
endif
" Look across all open buffers for completion options
let g:neocomplcache_same_filetype_lists._ = '_'

" Plugin key-mappings.
inoremap <expr><C-g> neocomplcache#undo_completion()
inoremap <expr><C-l> neocomplcache#complete_common_string()

" Use <TAB> completion
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Make Neocomplcache work with Tern, per
" https://github.com/Shougo/neocomplete.vim/issues/91
if !exists('g:neocomplcache_force_omni_patterns')
  let g:neocomplcache_force_omni_patterns = {}
endif
let g:neocomplcache_force_omni_patterns.javascript = '[^. \t]\.\w*'

" Add some language support
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" }}}

" Snippets {{{
" Disable default runtime snippets
let g:neosnippet#disable_runtime_snippets = {
\ '_': 1,
\ }
" }}}

" Colors {{{
" Set Colors
set background=dark

" Only looks good with 256 colors
if &t_Co >= 256
  " Make solarized work well in terminals
  let g:solarized_termcolors=256

  colorscheme solarized
else
  " Meh
  colorscheme desert
endif
" }}}

" GUI {{{
if has('gui_running')
  " Use a good font
  set guifont=Consolas:h14
  " Turn off toolbars
  set guioptions-=t
  set guioptions-=T
  " And scrollbars
  set guioptions-=r
  set guioptions-=L
  " Default to a reasonable window size
  set lines=40 columns=86 " Give space for line numbers
  " Use light colors
  set background=light
  colorscheme solarized
  " Map F5 for switching light/dark
  call togglebg#map("<F5>")
endif
" }}}

" Status Line {{{
" Always show statusline
set laststatus=2

" Make airline match main theme
let g:airline_theme = 'solarized'
" }}}

" Unite File/Buffer Explorer {{{
" Taken from this informative post:
" http://eblundell.com/thoughts/2013/08/15/Vim-CtrlP-behaviour-with-Unite.html
let g:unite_enable_start_insert = 1
let g:unite_split_rule = "botright"
let g:unite_force_overwrite_statusline = 0
let g:unite_winheight = 10

call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
\ 'ignore_pattern', join([
\ '\.git/',
\ ], '\|'))

call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])

" Map file/buffer list to leader-t
nnoremap <leader>t :<C-u>Unite -buffer-name=files -start-insert buffer file_rec/async:!<cr>
" BufExplorer-like mapping with leader-b
nnoremap <leader>b :<C-u>Unite -buffer-name=files -start-insert buffer bookmark<cr>

autocmd FileType unite call s:unite_settings()

function! s:unite_settings()
  imap <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
  imap <silent><buffer><expr> <C-x> unite#do_action('split')
  imap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  imap <silent><buffer><expr> <C-t> unite#do_action('tabopen')

  " Make Esc / Control-C close the explorer
  imap <buffer> <ESC> <Plug>(unite_exit)
  nmap <buffer> <ESC> <Plug>(unite_exit)
  nmap <C-c> <ESC> <Plug>(unite_exit)
endfunction
" }}}

" Unite Ack/Ag search {{{
nnoremap <leader>a :<C-U>Unite grep:.<cr>
" }}}

" Unite Yank history {{{
let g:unite_source_history_yank_enable = 1
" Save system clipboard value as well
let g:unite_source_history_yank_save_clipboard = 1
nnoremap <leader>y :<C-u>Unite history/yank<cr>
" }}}

" Projects, Filenames, and Search {{{
" Ignore source directories and some others
set wildignore+=*.o,*.obj,.git,node_modules,*.pyc

" Ignore lib/ dirs since the contain compiled libraries typically
set wildignore+=lib,build,public,_site

" Ignore images and fonts
set wildignore+=*.ttf,*.otf,*.svg,*.png,*.jpg,*.gif,*.jpeg

" Ignore case, except when using some uppercase
set ignorecase
set smartcase

" Show incremental search matches
set incsearch

" Match all results in a line by default
set gdefault

" }}}

" Folds {{{
" }}}

" Spelling {{{
" Turn on spell checking
set spell
" Toggle spell check
nnoremap <F7> :setlocal spell! spell?<CR>
" }}}

" VimShell {{{
"
" ,vs to open a quick pop-up shell for commands
nnoremap <silent> <leader>vs :VimShellPop<cr>

" ,vs(h|v) to open up shell in vertical/horizontal split
nnoremap <silent> <leader>hvs :VimShell -split -split-command=split<cr>
nnoremap <silent> <leader>vvs :VimShell -split -split-command=vsplit<cr>

" ,vsi(h|v) to open up interpreter
nnoremap <silent> <leader>hvsi :VimShellInteractive -split -split-command=split<cr>
nnoremap <silent> <leader>vvsi :VimShellInteractive -split -split-command=vsplit<cr>

" Send current selection to VimShell with <leader>vs
vnoremap <silent> <leader>vs :VimShellSendString<cr>

" TODO: Figure out why none of this works
" if !exists('g:vimshell_interactive_interpreter_commands')
"   let g:vimshell_interactive_interpreter_commands = {}
" endif
" let g:vimshell_interactive_interpreter_commands.javascript = 'node'
" let g:vimshell_interactive_interpreter_commands.coffee = 'coffee'
" }}}

" FileType tweaks {{{
" Enable marker folds in .vimrc
autocmd FileType vim set fdm=marker fdl=0
" Fold via indent in CoffeeScript and Python
autocmd BufNewFile,BufReadPost *.coffee setl foldmethod=indent
autocmd BufNewFile,BufReadPost *.py setl foldmethod=indent
"}}}

" Local Settings {{{
if filereadable(expand("~/.vimrc.local"))
  so ~/.vimrc.local
endif
" }}}
