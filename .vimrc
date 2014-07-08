" vim:fdm=marker ts=2 sts=2 sw=2 fdl=0

" Check if NeoBundle is installed by seeing if the README is there
if !filereadable(expand('~/.vim/bundle/neobundle.vim/README.md'))
  echo 'Must install NeoBundle. Run ~/dotfiles/setup.sh'
  echo 'Run vim -u NONE to open vim without .vimrc'
  exit
endif

" NeoBundle Setup {{{
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'
" }}}

" Bundles {{{
" Core Features
NeoBundle 'kien/ctrlp.vim'

" Editing features
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'godlygeek/tabular'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-rsi'
NeoBundle 'SirVer/ultisnips'
NeoBundle 'ervandew/supertab'

" Languages & Dev Tools {{{
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'gregsexton/gitv'
NeoBundleLazy 'marijnh/tern_for_vim', {
\   'build': {
\     'others': 'npm install',
\   },
\   'autoload': {
\     'filetypes': ['javascript']
\   }
\ }
NeoBundleLazy 'jelera/vim-javascript-syntax', {
\   'autoload': {
\     'filetypes': ['javascript']
\   }
\ }
NeoBundleLazy 'groenewege/vim-less', {
\   'autoload': {
\     'filetypes': ['less']
\   }
\ }
NeoBundleLazy 'mattn/emmet-vim', {
\   'autoload': {
\     'filetypes': ['html', 'css']
\   }
\ }
NeoBundleLazy 'kchmck/vim-coffee-script', {
\   'autoload': {
\     'filetypes': ['coffee']
\   }
\ }
NeoBundleLazy 'tpope/vim-liquid', {
\   'autoload': {
\     'filetypes': ['html', 'markdown']
\   }
\ }

" }}}

NeoBundle 'fortes/vim-personal-snippets'

" Colors & Display {{{
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'nathanaelkane/vim-indent-guides'
" Gutter & Status Line
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'bling/vim-bufferline'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'bling/vim-airline'
" }}}
" }}}

" NeoBundle Coda {{{
call neobundle#end()

filetype plugin on

" Check for uninstalled bundles and automatically install
NeoBundleCheck
" }}}

" Base Configuration {{{

" Sensible things {{{
" Welcome to the future
set nocompatible

" Display incomplete commands
set showcmd

" Hide default mode text (i.e. INSERT below status line)
set noshowmode

" Hide the intro screen, use [+] instead of [Modified], use [RO] instead
" of [readyonly]
set shortmess+=Imr

" Default to UTF-8
set encoding=utf-8
set termencoding=utf-8
set fileformats+=mac

" Make filename tab completion more bash-like
set wildmenu
set wildmode=longest,full

" Pretty much always on a fast connection
set ttyfast

" Mapping & keycode timeouts
set timeoutlen=300
set ttimeout
set ttimeoutlen=150

" Never forget
if &history < 1000
  set history=1000
endif

" Unix/windows compatibility
set viewoptions=cursor,folds,options,slash,unix

" Hide buffers instead of closing them (useful for switching between files)
set hidden

" Automatically reload modified files
set autoread

" Don't use modelines (security concerns)
set nomodeline

" Show cursor position in bottom right
set ruler

" Don't use backup files, we have Git for that
set nobackup
set noswapfile
set nowritebackup

" Disable visual bell
set noerrorbells
set visualbell t_vb=

" Always show statusline
set laststatus=2

" Support mouse
set mouse=a
set ttymouse=xterm2

" Make h/l move across beginning/end of line
set whichwrap+=hl

" Remove silly restrictions from backspace
set backspace=indent,eol,start

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

" Use system clipboard by default
set clipboard=unnamed

" }}}

" Indents, Wrapping, and Whitespace {{{
set autoindent

" 2 spaces, not tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
" Round up indents
set shiftround
set smarttab

" Use smart indenting
set cindent

" Automatically reselect visual block after indent
vnoremap < <gv
vnoremap > >gv

" Soft wrap, with indicator
set wrap
set showbreak=«
" Wrap at 80 characters
set textwidth=80
" Highlight textwidth column
set colorcolumn=+1

" Highlight current line and column when in insert mode
autocmd WinEnter,InsertEnter * set cursorline cursorcolumn
autocmd WinLeave,InsertLeave * set nocursorline nocursorcolumn

" Only break the line if wasn't longer than 80 chars when editing began
" and there is a blank somewhere in the line
set formatoptions+=lb
" Don't continue comments when pressing o/O
set formatoptions-=o
" Recognize numbered lists and wrap accordingly
set formatoptions+=n
" Remove comment leader when joining lines (added in Vim 7.4)
if version >= 740
  set formatoptions+=j
endif

" Allow incrementing letters
set nrformats+=alpha
" Always assume decimal numbers
set nrformats-=octal

" Show special indicators
set list
" Highlight trailing spaces
set listchars=trail:·,tab:»·
" Show wrap indicators
set listchars+=extends:»,precedes:«
" Show non-breaking spaces
set listchars+=nbsp:%

" Keep lines in view at edges of screen
set scrolloff=8
set sidescrolloff=7
set sidescroll=1

" Display as much as possible as last line, instead of just showing @
set display=lastline

" Use 5 characters for number well
set numberwidth=5
" }}}

" Colors {{{
set background=dark

if &t_Co >= 256
  silent! colorscheme jellybeans
else
  " Ugh, no colors
  colorscheme desert
endif
" }}}

" GUI {{{
if has('gui_running')
  " Use light colors
  set background=light
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
endif
" }}}

" Syntax Highlighting {{{
syntax enable

" Show matching brackets
set showmatch
set matchtime=2
" }}}

" Autocomplete {{{
" Only insert longest common text of matches & show menu when only one match
set completeopt=menuone,longest

" Control-K for omnicomplete
inoremap <C-k> <c-x><c-o><Down>
" Use Control-space to omnicomplete
inoremap <C-Space> <c-x><c-o><Down>
" In terminal, control-space makes a different character
inoremap <NUL> <C-X><C-O><Down>

" Escape closes the menu and goes back to what was there
inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
" Enter/Tab accepts the current match
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"

" Be smart about case when using autocomplete
set infercase

" Enable Omnicomplete
set omnifunc=syntaxcomplete#Complete
" }}}

" Efficiency Shortcuts {{{
" Use comma as leader
let mapleader=","
let g:mapleader=","

" Make ; equivalent to : (faster commands)
nnoremap ; :

" Hide annoying quit message
nnoremap <C-c> <C-c>:echo<cr>

" Map jj and jk to <ESC> to leave insert mode quickly
inoremap jj <ESC>
inoremap jk <ESC>

" Make j/k move screen visible lines, not file lines
nnoremap j gj
nnoremap k gk

" Never use the manual command, remap to search (see below)
nnoremap K <nop>

" Easy paste mode
nnoremap <silent> <leader>v :set invpaste<cr>

" Toggle line numbers
nnoremap <silent> <leader>n :set invnumber<cr>

" Navigate splits with control key
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
" Note: This overrides the normal <C-l> which redraws the screen
nnoremap <C-l> <C-l><C-w>l

" Navigate splits with arrow keys
nnoremap <left> <C-w>h
nnoremap <right> <C-w>l
nnoremap <up> <C-w>k
nnoremap <down> <C-w>j

" Close out non-modifable windows (quickfix, help, etc) with q, Escape,
" or Control-C
autocmd BufReadPost * if !&modifiable | nnoremap <buffer> q :q<cr> | endif
autocmd BufReadPost * if !&modifiable | nnoremap <buffer> <Esc> :q<cr> | endif
autocmd BufReadPost * if !&modifiable | nnoremap <buffer> <C-c> :q<cr> | endif

" <leader><leader> to switch to last file edited
nnoremap <leader><leader> <c-^>

" <leader>par to format the paragraph the cursor is currently in (or selection)
if executable('par')
  nnoremap <leader>par {!}par<CR>
  vnoremap <leader>par !par<CR>
endif

" }}}

" Projects, Filenames, and Search {{{
" Ignore source directories and some others
set wildignore+=*.o,*.obj,.git,node_modules,*.pyc

" Ignore lib/ dirs since the contain compiled libraries typically
set wildignore+=lib,build,public,_site,third_party

" Ignore images and fonts
set wildignore+=*.ttf,*.otf,*.svg,*.png,*.jpg,*.gif,*.jpeg

" Ignore case, except when using some uppercase
set ignorecase
set smartcase

" Show incremental search matches
set incsearch

" Match all results in a line by default
set gdefault

" Center cursor after jumping to next match
nnoremap n nzz

" Use ag/ack instead of grep, if available
if executable('ack')
  set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
  set grepformat=%f:%l:%c:%m
endif
if executable('ag')
  set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
  set grepformat=%f:%l:%c:%m
endif

" Prompt for search and show results in quicklist via <leader>a or \ (backslash)
" nnoremap <leader>a :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
if !exists(':Ag')
  command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
endif
nnoremap \ :Ag<SPACE>
nnoremap <leader>a :Ag<SPACE>

" Search for word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cwindow<CR>
" }}}

" Folds {{{
set foldenable
set foldmethod=marker
set foldnestmax=3
" Default to having folds open
set foldlevel=9
" }}}

" Spelling {{{
" Enable word completion from dictionary
set complete+=kspell

" Toggle spell check
nnoremap <F7> :setlocal spell! spell?<CR>
" }}}
" }}}

" FileType tweaks {{{

" Make views automatic
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview

" Some plugins will override the formatoptions, so this overrides them back
autocmd BufNewFile,BufReadPost * setlocal formatoptions+=lbon
" Stupid old vim on MacOS doesn't support 'j' formatoption
if version >= 740
  autocmd BufNewFile,BufReadPost * setlocal formatoptions+=j
endif

" Close folds in .vimrc
autocmd FileType vim set fdm=marker fdl=1

" Decent JS folding
autocmd FileType javascript call JavaScriptFold()

" Use esformatter for formatting JS
autocmd FileType javascript setlocal formatprg=esformatter

" <leader>tr to rename variable under cursor
autocmd FileType javascript nnoremap <leader>tr :TernRename<cr>
" <leader>td to go to definition
autocmd FileType javascript nnoremap <leader>td :TernDef<cr>

" Use html-beautify and css-beautify for respective types
autocmd FileType html setlocal formatprg=html-beautify\ -f\ -
autocmd FileType css setlocal formatprg=css-beautify\ -f\ -

" Fold via indent in CoffeeScript and Python
autocmd BufNewFile,BufReadPost *.coffee setlocal foldmethod=indent
autocmd BufNewFile,BufReadPost *.py setlocal foldmethod=indent

" Python uses 4 spaces
au FileType python setlocal shiftwidth=4

" Not all files should wrap automatically
autocmd BufNewFile,BufReadPost *.txt,*.md,*.markdown setlocal textwidth=0

" .md is markdown, not modula
autocmd BufRead,BufNewFile *.md set filetype=markdown

" Enable spell checking in some filetypes
autocmd BufNewFile,BufReadPost *.txt,*.md,*.markdown,COMMIT_EDITMSG
        \ setlocal spell
" Disable spell checking on unmodifiable files (what's the point?)
autocmd BufReadPost * if !&modifiable | setlocal nospell | endif

" Consider '-' part of a world when tab completion, etc
au FileType css setlocal iskeyword+=-
"}}}

" Plugin Configuration {{{

" CtrlP {{{
" <leader>p to search files, buffers, and MRU
nnoremap <silent> <leader>p :CtrlPMixed<cr>

" Don't jump to a window that is already open, but do jump to tabs
let g:ctrlp_switch_buffer = 't'

" List from top to bottom, like Cmd-T
let g:ctrlp_match_window_reversed = 0

" Use ag for listing files
if executable('ag')
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif
" }}}

" Airline {{{
" Use nice symbols (assumes patched fonts)
let g:airline_powerline_fonts = 1

" Better colors
let g:airline_theme='simple'
" }}}

" Bufferline {{{
" Should only be in airline
let g:bufferline_echo=0

" Make sure the current file is always visible
let g:bufferline_rotate=1
" }}}

" GitGutter {{{
" Toggle GitGutter with <leader>gl
nnoremap <silent> <leader>gg :GitGutterToggle<CR>
nnoremap <silent> <leader>gl :GitGutterLineHighlightsToggle<CR>

" Move between hunks with <leader>gn and <leader>gp
nnoremap <silent> <leader>gp :GitGutterPrevHunk<CR>
nnoremap <silent> <leader>gn :GitGutterNextHunk<CR>

" Ignore whitespace
let g:gitgutter_diff_args='-w'

" Use raw grep
let g:gitgutter_escape_grep=1

" Use highlighting as well as signs
let g:gitgutter_highlight_lines=1

" Be aggressive about looking for diffs
let g:gitgutter_realtime=1
let g:gitgutter_eager=1

" Change modified sign
let g:gitgutter_sign_modified='±'
" }}}

" Fugitive {{{
" Status with <leader>gs
nnoremap <silent> <leader>gs :Gstatus<CR>
" Diff with <leader>gd
nnoremap <silent> <leader>gd :Gdiff<CR>
" Commit with <leader>gc
nnoremap <silent> <leader>gc :Gcommit<CR>
" }}}

" Syntastic {{{
" Check on open
let g:syntastic_check_on_open=1

" Use nicer symbols
let g:syntastic_error_symbol = '✗'
let g:syntastic_style_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_style_warning_symbol = '⚠'

" JS Checking
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_javascript_jshint_args = '--config ~/.jshintrc'

" eslint is way too slow to run on every save
let g:syntastic_javascript_eslint_args = "--config ~/.eslintrc"
nnoremap <leader>esl :SyntasticCheck eslint<CR>

" Map leader-er to show syntastic errors
nnoremap <silent> <leader>er :Errors<CR>
" }}}

" Indent Guides {{{
" Default on
autocmd BufNewFile,BufReadPost * silent! IndentGuidesEnable

" Toggle Indent guides with <leader>ig
nnoremap <silent> <leader>ig :IndentGuidesToggle<CR>

" Don't use their colors
let g:indent_guides_auto_colors=0

" }}}

" Tabularize {{{
nnoremap <leader>l= :Tabularize /=<CR>
vnoremap <leader>l= :Tabularize /=<CR>
nnoremap <leader>l: :Tabularize /:<CR>
vnoremap <leader>l: :Tabularize /:<CR>
" }}}

" tcomment {{{
" Match old NERDCommenter bindings I got used to
nnoremap <leader>cc :TComment<CR>
vnoremap <leader>cc :TComment<CR>
vnoremap <leader>cu :TComment<CR>
" }}}

" CoffeeScript {{{
" <leader>-e Does CoffeeScript compilation in visual mode
vnoremap <silent> <leader>e :CoffeeCompile<cr>

" <leader>-r Runs CoffeeScript in visual mode
vnoremap <silent> <leader>r :CoffeeRun<cr>
" }}}

" Ultisnips {{{
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<C-Z>"
" }}}
" }}}

" Local Settings {{{
if filereadable(expand("~/.vimrc.local"))
  so ~/.vimrc.local
endif
" }}}
