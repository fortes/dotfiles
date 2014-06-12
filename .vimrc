" Must be first, since has side effects for other options
set nocompatible
filetype off

" Force 256 colors on load
" set t_Co=256

" Load up Vundle
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" let Vundle manage Vundle (required!)
Plugin 'gmarik/vundle'

" Bundles go here
" Colors
Plugin 'fortes/vim-railscasts'
Plugin 'altercation/vim-colors-solarized'
" Languages
Plugin 'groenewege/vim-less'
Plugin 'kchmck/vim-coffee-script'
Plugin 'pangloss/vim-javascript'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'moll/vim-node'
Plugin 'othree/html5.vim'
Plugin 'tpope/vim-haml'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-surround'
Plugin 'vim-scripts/JSON.vim'
Plugin 'vim-scripts/Python-Syntax'
Plugin 'vim-scripts/Python-Syntax-Folding'
Plugin 'vim-scripts/python.vim--Vasiliev'
" Snippets
Plugin 'garbas/vim-snipmate'
Plugin 'fortes/vim-coffeescript-snippets'
Plugin 'ervandew/supertab'
" Statusline
Plugin 'bling/vim-airline'
Plugin 'bling/vim-bufferline'
" Other
Plugin 'Lokaltog/vim-easymotion'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'Townk/vim-autoclose'
Plugin 'mhinz/vim-signify'
Plugin 'benmills/vimux'
Plugin 'conormcd/matchindent.vim'
Plugin 'gregsexton/gitv'
Plugin 'kien/ctrlp.vim'
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'mileszs/ack.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'tomtom/tlib_vim'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-scripts/indent-motion'
Plugin 'vim-scripts/matchit.zip'
Plugin 'godlygeek/tabular'

call vundle#end()

" Enable plugins and languages
filetype plugin indent on

"""""""""""""""""""
" Global Settings
"""""""""""""""""""

" Turn off 'Thanks for flying Vim' message
if has('notitle')
  set notitle
else
  let &titleold=getcwd()
endif

" Hide default mode text (i.e. INSERT below status line)
set noshowmode

" Default to UTF-8
set encoding=utf-8
set termencoding=utf-8

" Default to UNIX file formats
set fileformats=unix,dos,mac

" Pretty much always on a fast connection
set ttyfast

" Hide the intro screen
set shortmess+=I

" Don't use modelines (security concerns)
set modelines=0

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

" Set Colors
set background=dark

" Only looks good with 256 colors
if &t_Co >= 256
  " Make solarized work well in terimnals
  let g:solarized_termcolors=256

  silent! colorscheme railscasts
  "colorscheme solarized
else
  " Meh
  colorscheme desert
endif

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

" Use comma as leader
let mapleader=","

" Have space PageDown, like in more
nnoremap <space> <C-f>
" Make backspce PageUp
nnoremap <Backspace> <C-b>

" Never use the manual command
nnoremap K <nop>

" Stay fast by not going too far back to figure out syntax highlighting
syntax sync minlines=64

" Ignore source directories and some others
set wildignore+=*.o,*.obj,.git,node_modules,*.pyc

" Ignore lib/ dirs since the contain compiled libraries typically
set wildignore+=lib,build,public,_site

" Ignore images and fonts
set wildignore+=*.ttf,*.otf,*.svg,*.png,*.jpg,*.gif,*.jpeg

" Tell NERDtree to ignore common directories
let NERDTreeIgnore=['node_modules$[[dir]]', 'lib$[[dir]]', 'build$[[dir]]']

""""""""""""""""
" Status Line
""""""""""""""""

" Always show statusline
set laststatus=2

" Bufferline should only be in airline
let g:bufferline_echo=0

" Make sure the current file is always visible
let g:bufferline_rotate=1

" Remove separators
let g:airline_left_sep=''
let g:airline_right_sep=''

"""""""""""""""""""
" Autocomplete
"""""""""""""""""""

" Consider '-' part of a world when tab completion, etc
set iskeyword+=-

" Enable Omnicomplete
set ofu=syntaxcomplete#Complete

" Allow type-filtering when using tab completion (use longest common text)
set completeopt+=longest

" Use Control-Space for autocomplete
if has("gui_running")
  inoremap <C-Space> <C-n>
else
  inoremap <Nul> <C-n>
end

" Supertab should use omnicomplete by default
"let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
"let g:SuperTabDefaultCompletionType = "context"
"let g:SuperTabContextDefaultCompletionType= "<c-x><c-o>"

"""""""""""""""""""
" UltiSnips
"""""""""""""""""""

" Directory where private snippet definition files are stored
let g:UltiSnipsSnippetDirectories = ["snippets"]

" Bind to Tab
let g:UltiSnipsExpandTrigger="<tab>"                                                               | 
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

"""""""""""""""""""
" Editing
"""""""""""""""""""

" Remove silly restrictions from backspace
set backspace=indent,eol,start

" Make tab completion more bash-like
set wildmenu
set wildmode=longest,full

" Support mouse
set mouse=a
set ttymouse=xterm2

" Map jj and jk to <ESC> to leave insert mode quickly
inoremap jj <ESC>
inoremap jk <ESC>

" Make j/k move screen visible lines, not file lines
nnoremap j gj
nnoremap k gk

" Make h/l move across beginning/end of line
set whichwrap+=hl

" Make ; equivalent to : (faster commands)
nnoremap ; :

" <leader>-n toggles line numbers
nnoremap <silent> <leader>n :set invnumber<cr>

" <leader>-v toggles paste mode
nnoremap <silent> <leader>v :set invpaste<cr>

" <leader>-e Does CoffeeScript compilation in visual mode
vnoremap <silent> <leader>e :CoffeeCompile<cr>

" <leader>-r Runs CoffeeScript in visual mode
vnoremap <silent> <leader>r :CoffeeRun<cr>

" Tab in normal mode can indent
nnoremap <Tab> >>
nnoremap <S-Tab> <<

" Use tab when in visual mode for indentation, while maintaining selection
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Tabularize shortcuts
if exists(":Tabularize")
  "nmap <Leader>a= :Tabularize /=<CR>
  "vmap <Leader>a= :Tabularize /=<CR>
  "nmap <Leader>a: :Tabularize /:\zs<CR>
  "vmap <Leader>a: :Tabularize /:\zs<CR>
endif

"""""""""""""""
" Misc Plugins
"""""""""""""""

" Use <leader><tab> to toggle NERDTree visibility
nnoremap <silent> <leader><tab> :NERDTreeToggle<cr>

" Set CoffeeCompile to be vertical
let coffee_compile_vert = 1

" <leader>-gg toggles Git Gutter
nnoremap <silent> <leader>gg :ToggleGitGutter<cr>
" <leader>-gh to toggle Git Highlight
nnoremap <silent> <leader>gh :ToggleGitGutterLineHighlights<cr>
" Jump to next / prev change hunks
nnoremap <silent> <leader>gj :GitGutterNextHunk<cr>
nnoremap <silent> <leader>gk :GitGutterPrevHunk<cr>

" Clear sign column highlight
" highlight clear SignColumn

"""""""""
" Vimux
"""""""""

" Use exising pane (not used by vim) if found instead of running split-window.
let VimuxUseNearestPane = 1

" Use <leader>rp to run a command in Tmux pane below
nnoremap <leader>rp :VimuxPromptCommand<cr>
" <leader>rr repeats last command
nnoremap <silent> <leader>rr :VimuxRunLastCommand<cr>
" <leader>rc kills the command
nnoremap <silent> <leader>rc :VimuxInterruptRunner<cr>
" <leader>rq closes the bottom pane
nnoremap <silent> <leader>rq :VimuxCloseRunner<cr>
" <leader>rx closes all panes
nnoremap <silent> <leader>rx :VimuxClosePanes<cr>
" Inspect runner pane
nnoremap <silent> <leader>ri :VimuxInspectRunner<cr>

""""""""""""
" Buffers
""""""""""""

" Hide buffers instead of closing them (useful for switching between files)
set hidden

"""""""""
" CtrlP
"""""""""

" Alias Cmd-T shortcuts for CtrlP
" <leader>t to search
nnoremap <silent> <leader>t :CtrlP<cr>

" <leader>b to open buffers
nnoremap <silent> <leader>b :CtrlPBuffer<cr>

" Don't jump to a window that is already open, but do jump to tabs
let g:ctrlp_switch_buffer = 't'

" List from top to bottom, like Cmd-T
let g:ctrlp_match_window_reversed = 0

"""""""""
" Splits
"""""""""

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

" Use control key modifier to move between split windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
" Note: This overrides the normal <C-l> which redraws the screen
nnoremap <C-l> <C-l><C-w>l

"" Hold down alt to change size of splits
"map <silent> <A-h> <C-w><
"map <silent> <A-j> <C-w>-
"map <silent> <A-k> <C-w>+
"map <silent> <A-l> <C-w>>
""nnoremap <A-h> <C-w><
""nnoremap <A-j> <C-w>-
""nnoremap <A-k> <C-w>+
""nnoremap <A-l> <C-w>>

"""""""""""
" Folding
"""""""""""

set foldmethod=indent
set foldnestmax=3
set nofoldenable
" Default to having folds open
set foldlevel=9
" Have leader-space toggle folds
nnoremap <leader><space> za

""""""""""""""""""""""
" Indents and Wrapping
""""""""""""""""""""""

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

" Some files shouldn't be wrapped automatically
autocmd BufRead,BufNewFile *.txt,*.md,*.markdown setlocal textwidth=0

" Vim 7.3 adds support for highlighting cols after textwidth
if exists('+colorcolumn')
  set colorcolumn=+1
else
  " Fallback for older Vim
  au BufWinEnter * let w:m2=matchadd('ColorColumn', '\%>80v.\+', -1)
endif

" Highlight current line and column when in insert mode
autocmd InsertEnter * set cursorline cursorcolumn
autocmd InsertLeave * set nocursorline nocursorcolumn

" Highlight trailing spaces
set listchars=trail:.,tab:»·
set list

" Keep lines in view at edges of screen
set scrolloff=8
set sidescrolloff=7
set sidescroll=1

" Scroll a few lines by default with Ctrl-E and -Y
nnoremap <C-e> 15<C-e>
nnoremap <C-y> 15<C-y>

"""""""""""""""""""""""
" Syntax Highlighting
"""""""""""""""""""""""

syntax on

" Show matching brackets
set showmatch
set matchtime=2

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

""""""""""
" Search
""""""""""

" Ignore case, except when using some uppercase
set ignorecase
set smartcase

" Highlight search and show incremental matches
"set hlsearch
set incsearch

" Use standard Perl/Python syntax for regex
"nnoremap / /\v
"vnoremap / /\v

" Clear out search highlight with <leader>/
nnoremap <leader>/ :nohls<cr>
" Control-L in insert mode clears highlight (and redraws screen)
inoremap <C-L> <C-O>:nohls<cr><C-O><C-L>

" Search globally by default
set gdefault

" Ack for the last search
nnoremap <silent> <leader>? :execute "Ack! '" . substitute(substitute(substitute(@/, "\\\\<", "\\\\b", ""), "\\\\>", "\\\\b", ""), "\\\\v", "", "") . "'"<CR>

" Ack shortcut
map <leader>a :Ack! 

"""""""""""""
" Tabs
"""""""""""""

" Show tab line only if there is more than one tab
set showtabline=1

"""""""""""
" Tagbar
"""""""""""

" Automatically close after use
let g:tagbar_autoclose = 0

" Focus on open
let g:tagbar_autofocus = 1

" Sort by file order by default
let g:tagbar_sort = 1

" Use compact mode
let g:tagbar_compact = 1

""""""""""""""
" Syntastic
""""""""""""""

let g:syntastic_javascript_checkers = ['gjslint', 'jshint']

"let g:syntastic_coffee_lint_options = "-f ~/.coffeelint.json"
let g:syntastic_javascript_jshint_conf = "~/.jshintrc"

" eslint is way too slow to run on every save
let g:syntastic_javascript_eslint_conf = "~/.eslintrc"
nnoremap <leader>eslint :SyntasticCheck eslint<CR>

" Map leader-er to show syntastic errors
nnoremap <silent> <leader>er :Errors<CR>

""""""""""""""""""""
" Misc commands
""""""""""""""""""""

" Format JSON
nnoremap <leader>json :%!python -mjson.tool<CR>

" Remove trailing whitespace
nnoremap <leader>whitespace :%s/\s\+$<CR>

"""""""""""""""""
" Local Settings
"""""""""""""""""

" Load only if file exists
if filereadable(expand("~/.vimrc.local"))
  so ~/.vimrc.local
endif
