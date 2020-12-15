" vim:fdm=marker et fdl=2 ft=vim sts=2 sw=2 ts=2
" Use modern encoding
set encoding=utf-8
scriptencoding utf-8

" Configuration for vanilla (neo)vim, with no plugins

" Neovim-vim deltas {{{
if !has('nvim')
  " Default vaules (or removed) in Neovim (see :help vim-differences). Make sure
  " we're working with the same baseline here.

  " Basic auto indentation
  set autoindent
  " Automatically reload modified files
  set autoread
  " Remove silly restrictions from backspace
  set backspace=indent,eol,start
  " Shhhh
  set belloff=all
  " Don't scan included files for keyword completion (too slow)
  set complete-=i
  " Display as much as possible as last line, instead of just showing @
  set display=lastline,msgsep
  " Default formatoptions in neovim: tcqj
  " t Wrap text using textwidth
  " c Wrap comments using textwidth, inserting comment leader automatically.
  " q Allow formatting of comments with "gq"
  set formatoptions=tcq
  if v:version >= 704
    " j Remove comment leader when joining lines (added in Vim 7.4)
    set formatoptions+=j
  endif
  " Default history store
  set history=10000
  " Highlight search results
  set hlsearch
  " Show incremental search matches
  set incsearch
  if has('langmap') && (v:version > 704 || v:version == 704 && has('patch502'))
    " Disable langmap for characters from a mapping (on by default in neovim)
    set langnoremap
  endif
  " Support mouse
  set mouse=a
  " The future is now!
  set nocompatible
  " Show cursor position in bottom right
  set ruler
  " Neovim default
  set sessionoptions-=options
  " Backspace should delete tabwidth of characters
  set smarttab
  " More tabs at once (match neovim default)
  set tabpagemax=50
  " Default tag store
  set tags="./tags;,tags"
  " On modern terminals
  set ttyfast
  " No longer exists in Neovim
  set ttymouse=xterm2
  " Makes filename tab completion more bash-like
  set wildmenu
endif
" }}}

" Base Configuration {{{

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &runtimepath) ==# ''
  runtime! macros/matchit.vim
endif

" Core Behavior {{{
" Disable for security reasons. `securemodelines` plugin helps here
set nomodeline

" Read .vimrc from current dir, if present
set exrc

" Don't allow shell and write commands in exrc
set secure

" Enable loading plugin / indent settings based on filetype
filetype plugin indent on

" Don't redraw while executing macros, etc
set lazyredraw

" Wait just under a second before CursorHold is fired
set updatetime=750

" Mapping & keycode timeouts
set timeoutlen=600
set ttimeout
set ttimeoutlen=200
" }}}

" UI {{{
" Maintain indent when wrapping
if exists('+breakindent')
  set breakindent
endif

" Highlight textwidth column
set colorcolumn=+1

" Folds {{{
" Auto-close folds below current foldlevel when cursor leaves
set foldclose=all

" Enable folds, using markers by default
set foldenable
set foldmethod=marker

" Default to having all folds open
set foldlevelstart=99

" Limit folds when using indent or syntax
set foldnestmax=5

set foldopen+=jump
" }}}

" Enable live substitution
if exists('&inccommand')
  set inccommand=split
endif

" TODO: Feature check
augroup HiglightedYank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}
augroup END

" Always show statusline
set laststatus=2

" Let same document scroll differently in separate panes
set noscrollbind

" Hide default mode text (i.e. INSERT below status line)
set noshowmode

" Use 5 characters for number well
set numberwidth=5

" Disable visual bell
set noerrorbells
set visualbell t_vb=

" Keep lines in view at edges of screen
set scrolloff=5
set sidescrolloff=5
set sidescroll=1

" Hide the intro screen, use [+] instead of [Modified], use [RO] instead
" of [readyonly], and don't give completion match messages
set shortmess+=Imrc

" Display incomplete commands
set showcmd

" Always show the signcolumn to avoid jitter
set signcolumn=yes

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Reasonable tab completion
set wildmode=full

" Resize splits when the window is resized
augroup on_vim_resized
  autocmd!
  autocmd VimResized * wincmd =
augroup END
" }}}

" File Handling {{{
" Automatically change directory to that of current file
set autochdir

" Automatically write files on :next, :make, etc
set autowriteall

" Save automatically all the time
augroup auto_save
  autocmd!
  " Frequently save automatically
  autocmd BufLeave,FocusLost,InsertLeave,TextChanged * silent! wall
  " Check for file changes
  autocmd BufEnter,BufWinEnter,CursorHold,FocusGained * silent! checktime
augroup END

" Support mac files
set fileformats+=mac

" Hide buffers instead of closing them (useful for switching between files)
set hidden

" Don't use backup files, we have Git for that
set nobackup
set noswapfile
set nowritebackup

" Search within subfolders by default
set path+=**
" But ignore noise
set path-=.git,build,lib,node_modules,public,_site,third_party

" Ignore autogenerated files
set wildignore+=*.o,*.obj,*.pyc
" Ignore source control
set wildignore+=.git
" Ignore lib/ dirs since the contain compiled libraries typically
set wildignore+=build,lib,node_modules,public,_site,third_party
" Ignore images and fonts
set wildignore+=*.gif,*.jpg,*.jpeg,*.otf,*.png,*.svg,*.ttf
" Ignore case when completing
set wildignorecase
" }}}

" Status line {{{
if v:version >= 704
  " Show git repo information (if available)
  let g:activeStatusLine='%{StatuslineTag()}»'
else
  let g:activeStatusLine=''
endif
" Relative path to file in current buffer
let g:activeStatusLine.='%<%f '
" Exclamation mark if not modifiable, + if modified
let g:activeStatusLine.="%{&readonly ? \"! \" : &modified ? '+ ' : ''}"
" Start left align, show filetype
let g:activeStatusLine.="%= %{&filetype == '' ? 'none' : &filetype} "
" Line/col/percent
let g:activeStatusLine.='%l:%2c '
function! StatuslineTag()
  if exists('b:git_dir')
    " Shitty unicode character w/o patched fonts
    return "‡".fugitive#head(7)
  else
    return fnamemodify(getwinvar(0, 'getcwd', getcwd()), ':t')
  endif
endfunction

let g:quickfixStatusLine="%t (%l of %L)"
let g:quickfixStatusLine.="%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''}"
let g:quickfixStatusLine.="%=%-15(%l,%c%V%) %P"

" Default status line
let statusline=g:activeStatusLine

" Use different status line for active vs. inactive buffers
function! UpdateStatusLine(status)
  if &filetype=="qf"
    let &l:statusline=g:quickfixStatusLine
  elseif &filetype=="help" || &filetype=="netrw"
    let &l:statusline=&filetype
  elseif a:status
    let &l:statusline=g:activeStatusLine
  else
    " Just show filename & modified when inactive
    let &l:statusline='%f %{&modified ? "+" : ""}'
  endif
endfunction

augroup status_line
  autocmd!
  autocmd BufWinEnter,BufEnter,TabEnter,VimEnter,WinEnter * call UpdateStatusLine(1)
  autocmd BufLeave,TabLeave,WinLeave * call UpdateStatusLine(0)
augroup END
" }}}

" Editing Behavior {{{
" Indentation {{{
" C-style indentation
set cindent

" Tabs are spaces
set expandtab

" 2 spaces, not tabs
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Round up indents
set shiftround
" }}}

" Completion {{{
" Keyword completion brings in the dictionary if spell check is enabled
set complete+=kspell

" Show menu when only one match, don't insert until match selected,
" and don't autoselect a match
set completeopt=longest,menuone,noinsert,noselect

" Make sure there's a default dictionary for completion
if filereadable('/usr/share/dict/words')
  set dictionary+=/usr/share/dict/words
endif

" Make completion work a bit more like traditional IDEs w/o losing useful keys

" Enable tab navigation between completion items
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Enter to confirm completion item
inoremap <silent><expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

" PageUp/PageDown doesn't select item by default
inoremap <silent><expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
inoremap <silent><expr> <PageUp> pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"
" }}}

" Default formatoptions (as of neovim): tcqj
" Only break the line if wasn't longer than 80 chars when editing began
" and there is a blank somewhere in the line
set formatoptions+=lb
" Don't continue comments when pressing o/O
set formatoptions-=o
" Recognize numbered lists and wrap accordingly
set formatoptions+=n

" Show special indicators
set list
" Highlight trailing spaces
set listchars=trail:·,tab:»·
" Show wrap indicators
set listchars+=extends:»,precedes:«
" Show non-breaking spaces
set listchars+=nbsp:%

" Allow incrementing letters
set nrformats+=alpha

" Always assume decimal numbers
set nrformats-=octal

" Show matching brackets for half a second
set showmatch
set matchtime=5

" Wrap at 80 characters
set textwidth=80

" Make h/l move across beginning/end of line
set whichwrap+=hl

" Soft wrap, with indicator
set wrap
set showbreak=«
" }}}

" Colors & Syntax Highlighting {{{
" Base install has some lame themes, this one is OK, I guess
silent! colorscheme delek

" Enable syntax highlighting by default
syntax enable

" Only highlight first 500 chars for better performance
set synmaxcol=500
" }}}

" Searching {{{
" Match all results in a line by default (/g at end will undo this)
set gdefault

" Ignore case, except when using some uppercase
set ignorecase
set smartcase

" Clear search highlights with <C-L>
nnoremap <silent> <C-L> :nohlsearch<cr><C-L>

" Helper for visual search
function! s:VisualSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" */# in visual mode searches for selected text, similar to normal mode
vnoremap * :<C-u>call <SID>VisualSetSearch('/')<cr>/<C-R>=@/<cr><cr>
vnoremap # :<C-u>call <SID>VisualSetSearch('#')<cr>/<C-R>=@/<cr><cr>

" <leader>s starts a find a replace for word under cursor
nnoremap <leader>s :%s/\<<C-R><C-W>\>/<C-R><C-W>/g<Left><Left>

function! IsInsideGitRepo()
  let result=systemlist('git rev-parse --is-inside-work-tree')
  if v:shell_error
    return 0
  else
    return 1
  endif
endfunction

" Change to git root of current file (if in a repo)
function! FindGitRootCD()
  let root = systemlist('git -C ' . expand('%:p:h') . ' rev-parse --show-toplevel')[0]
  if v:shell_error
    return ''
  else
    return {'dir': root}
  endif
endfunction

function! GitRootCD()
  let result = FindGitRootCD()
  if type(result) == type({})
    execute 'lcd' fnameescape(result['dir'])
    echo 'Now in '.result['dir']
  else
    echo 'Not in git repo!'
  endif
endfunction
command! GitRootCD :call GitRootCD()

" K searches for word under cursor in root of project (remove default binding)
nnoremap K :GitRootCD<cr>:silent! lgrep! "<C-R><C-W>"<cr>
" Grep for visual selection, just like in normal mode. Note that this clears /
" uses the `s` register
vnoremap K :<C-u>norm! gv"sy<cr>:GitRootCD<cr>:silent! lgrep! "<C-R>s"<cr>
" Never use Ex-mode, map to project search command instead
nnoremap Q :GitRootCD<cr>:lgrep!<SPACE>

" Automatically open quickfix/location list after grep/make
augroup auto_quickfix
  autocmd!
  " Make sure to redraw to avoid strange render bugs
  autocmd QuickFixCmdPost lgrep lwindow|redraw!
  autocmd QuickFixCmdPost grep,make cwindow|redraw!
augroup END

" Use ag instead of grep, if available
if executable('ag')
  " Use smart case, match whole words, and output in vim-friendly format
  set grepprg=ag\ -S\ -Q\ --nogroup\ --nocolor\ --vimgrep
  set grepformat^=%f:%l:%c:%m
else
  " Mimic ag settings (literal, recursive, ignore common directories)
  set grepprg=grep\ -FIinrw\ --exclude-dir=.git\ --exclude-dir=node_modules

  " Unlike ag, grep needs to have a file path after the search command. Add that
  " in for the K bindings (default to current directory)
  nnoremap K :GitRootCD<cr>:lgrep! "<C-R><C-W>" .<cr>
  vnoremap K :<C-u>norm! gv"sy<cr>:GitRootCD<cr>:lgrep! "<C-R>s" .<cr>
  nnoremap Q :GitRootCD<cr>:lgrep!<SPACE><SPACE>.<LEFT><LEFT>
endif
" }}}

" Efficiency Shortcuts {{{
" Use space as leader
let mapleader=" "
let maplocalleader=" "

" Use enter as colon for faster commands
nnoremap <cr> :
vnoremap <cr> :
" Meta-enter in case you need an actual <cr>
nnoremap <M-cr> <cr>
vnoremap <M-cr> <cr>

" Kick the habit of using <C-c> instead of <C-[>, since <C-c> breaks
" nvim-completion-manager
inoremap <C-c> <C-[>:echom "Use C-[ instead!"<cr>

" Close quickfix & help with q, Escape, or Control-C
" Also, keep default <cr> binding
augroup easy_close
  autocmd!
  autocmd FileType help,qf nnoremap <buffer> q :q<cr>
  autocmd FileType help,qf nnoremap <buffer> <Esc> :q<cr>
  autocmd FileType help,qf nnoremap <buffer> <C-c> :q<cr>
  " Undo <cr> -> : shortcut
  autocmd FileType help,qf nnoremap <buffer> <cr> <cr>
augroup END

" Map jj and jk to <ESC> to leave insert mode quickly
inoremap jj <ESC>
inoremap jk <ESC>

" Make j/k move screen visible lines, not file lines
nnoremap j gj
nnoremap k gk

" Move current line / visual line selection up or down.
" Taken from https://github.com/airblade/dotvim/
nnoremap <C-j> :m+<CR>==
nnoremap <C-k> :m-2<CR>==
vnoremap <C-j> :m'>+<CR>gv=gv
vnoremap <C-k> :m-2<CR>gv=gv

" CTRL-U for undo in insert mode
inoremap <C-U> <C-G>u<C-U>

" Never use ZZ, too dangerous
nnoremap ZZ <nop>

" Use tab and shift-tab to cycle through windows.
nnoremap <Tab> <C-W>w
nnoremap <S-Tab> <C-W>W

" Run `.` or macro over selected lines, taken from:
" https://reddit.com/r/vim/comments/3y2mgt
vnoremap . :normal .<CR>
vnoremap @ :normal @

" Use | and _ to split windows (while preserving original behaviour of
" [count]bar and [count]_).
" Stolen from http://howivim.com/2016/andy-stewart/
nnoremap <expr><silent> <Bar> v:count == 0 ? "<C-W>v<C-W><Right>" : ":<C-U>normal! 0".v:count."<Bar><CR>"
nnoremap <expr><silent> _     v:count == 0 ? "<C-W>s<C-W><Down>"  : ":<C-U>normal! ".v:count."_<CR>"

" Delete buffer via <C-W>d since I don't use tags
nnoremap <C-w>d :bd<cr>
nnoremap <C-w><C-d> :bd<cr>

" Unimpaired-style toggling of paste mode (and print result)
nnoremap cop :set invpaste<cr>:set paste?<cr>

" Change local directory to current file
nnoremap <leader>lcd :lcd %:p:h<cr>
" Go back to root
nnoremap <leader>cd :GitRootCD<cr>

" Quickly edit current buffer in a new tab (poor-man's maximize)
nnoremap <leader>te :tabedit %<cr>

" Quickly open tab
nnoremap <leader>tn :tabnew<cr>

" Close a tab
nnoremap <leader>tc :tabclose<cr>

" Easy editing & reloading of .nvimrc
nnoremap <leader>ev :tabedit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Sort lines within braces with <leader>s{
nnoremap <leader>s{ vi{:sort<cr>
" }}}

" }}}

" Filetype configuration {{{
augroup filetype_tweaks
  autocmd!
  " Recognize typescript
  autocmd BufNewFile,BufReadPost *.ts set filetype=typescript
  autocmd BufNewFile,BufReadPost *.tsx set filetype=typescript.tsx

  " .md is markdown, not modula
  autocmd BufNewFile,BufReadPost *.md,README,TODO set filetype=markdown

  " Not all files should wrap automatically
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.json,*.conf,*.ini,*.pug
    \ setlocal textwidth=0

  " Enable spell checking & linebreaking at words in some filetypes
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.markdown,COMMIT_EDITMSG
    \ setlocal spell linebreak

  " Disable spell checking on unmodifiable files (what's the point?)
  autocmd BufReadPost * if !&modifiable | setlocal nospell | endif

  " ES6 is JS
  autocmd BufRead,BufNewFile *.es6 set filetype=javascript

  let s:automake_filetypes = []

  " Set up linting for JS
  if executable('eslint')
    let s:automake_filetypes += ['*.js']

    autocmd FileType javascript setlocal makeprg=eslint\ -f\ compact\ %

    " Parse eslint errors correctly
    autocmd FileType javascript setlocal
          \ errorformat=%E%f:\ line\ %l\\,\ col\ %c\\,\ Error\ -\ %m
    autocmd FileType javascript setlocal
          \ errorformat+=%W%f:\ line\ %l\\,\ col\ %c\\,\ Warning\ -\ %m
    " Ignore lines that don't match the above
    autocmd FileType javascript setlocal errorformat+=%-G%.%#
  endif

  " TypeScript type checking
  if executable('tsc')
    let s:automake_filetypes += ['*.ts']

    autocmd FileType typescript setlocal makeprg=tsc\ --allowJs\ --noEmit\ --strict\ %\

    autocmd FileType typescript setlocal errorformat=%E%f(%l\\,%c):\ error\ %m
    autocmd FileType typescript setlocal errorformat+=%W%f(%l\\,%c):\ warning\ %m

    " Ignore TS usage warnings when type checking disabled
    autocmd FileType typescript setlocal errorformat+=%-GWarning:\ %m,

    " Ignore remaining non-matching lines
    autocmd FileType typescript setlocal errorformat+=%-G%.%#,
  endif

  " Linting for LESS
  if executable('lessc')
    let s:automake_filetypes += ['*.less']

    autocmd FileType less setlocal makeprg=lessc\ --lint\ --no-color\ %
    autocmd FileType less setlocal
          \ errorformat=%E%.%#Error:\ %m\ in\ %f\ on\ line\ %l\\,\ column\ %c:
    " Ignore unmatched lines
    autocmd FileType less setlocal errorformat+=%-G%.%#
  endif

  " CSS linting
  if executable('stylelint')
    let s:automake_filetypes += ['*.css']

    autocmd FileType css setlocal
          \ makeprg=stylelint\ %\ --no-color\ --fix\ --cache
    " Push/pop filename on stack with %P%f
    autocmd FileType css setlocal
          \ errorformat+=%P%f,%*[\ ]%l:%c%*[\ ]✖%*[\ ]%m
    " Ignore unmatched lines
    autocmd FileType css setlocal errorformat+=%-G%.%#
  endif

  " Linting for shell scripts
  if executable('shellcheck')
    let s:automake_filetypes += ['*.sh']

    autocmd FileType sh setlocal makeprg=shellcheck\ -x\ -f\ gcc\ %
  endif

  " Linting for prose
  if executable('proselint')
    let s:automake_filetypes += ['*.md', '*.txt']

    autocmd FileType markdown,text setlocal makeprg=proselint\ %
  endif

  " Linting for vimscript
  if executable('vint')
    let s:automake_filetypes += ['*.vim', '*.vimrc']

    autocmd FileType vim setlocal makeprg=vint\ --enable-neovim\ \-s\ %
  endif

  " Auto-make for supported filetypes
  augroup automake
    autocmd!
    " TODO: This may be breaking disabling automake because of this eval
    execute 'autocmd BufWritePost ' . join(s:automake_filetypes, ',') . ' make!'
  augroup END

  if executable('beautysh')
    autocmd FileType sh setlocal formatprg=beautysh\ -i\ 2\ -f\ -
  endif

  " Use prettier to autoformat (gq in Visual mode)
  if executable('prettier')
    autocmd FileType javascript setlocal formatprg=prettier\ --stdin\ --parser\ flow
    autocmd FileType typescript,typescript.tsx setlocal formatprg=prettier\ --stdin\ --parser\ typescript
    autocmd FileType json setlocal formatprg=prettier\ --stdin\ --parser\ json

    autocmd FileType css,less setlocal formatprg=prettier\ --parser\ css
    autocmd FileType html setlocal formatprg=prettier\ --parser\ html

    autocmd FileType markdown setlocal formatprg=prettier\ --parser\ markdown
    autocmd FileType yaml setlocal formatprg=prettier\ --parser\ yaml
  endif

  if executable('yapf')
    autocmd FileType python setlocal formatprg=yapf
  endif

  if executable('refmt')
    autocmd FileType reason setlocal formatprg=refmt
  endif

  " Find .js files when using `gf` (useful with require)
  autocmd FileType javascript setlocal suffixesadd=.js,.json,index.js
  autocmd FileType typescript setlocal suffixesadd=.ts,.tsx,.js,.jsx,.json,index.js

  autocmd FileType markdown setlocal suffixesadd=.md,index.md

  " Alphabetic sort for import in JS (use on paragraph via leader si)
  autocmd FileType javascript command!
    \  -range=% Isort :<line1>,<line2>sort/^const {\=/
  autocmd FileType javascript nnoremap <leader>s{ vip:Isort<cr>

  " Use folds in .vimrc
  autocmd FileType vim set fdm=marker fdl=9

  " Consider '-' part of a world when tab completion, etc in css/less
  autocmd FileType css,less setlocal iskeyword+=-

  " Simple folding for CSS/LESS
  autocmd FileType css,less setlocal fdm=marker fmr={,}

  " Fold via indent in CoffeeScript and Python
  autocmd FileType coffee,python setlocal foldmethod=indent

  " Fold via syntax for JS/TypeScript
  autocmd FileType javascript,typescript setlocal foldmethod=syntax

  " Makefiles use tabs
  autocmd FileType make setlocal noexpandtab shiftwidth=4

  " Python uses 4 spaces
  autocmd FileType python setlocal shiftwidth=4

  " Don't wrap in quickfix, and don't show in buffer list
  autocmd FileType qf setlocal nowrap textwidth=0 nobuflisted
  " Open in splits/tabs via s/v/t, partially cribbed from:
  " https://github.com/romainl/vim-qf/blob/master/after/ftplugin/qf.vim
  autocmd FileType qf nnoremap <buffer> s <C-W><CR><C-W>x<C-W>k
  autocmd FileType qf nnoremap <buffer> v <C-W><CR><C-W>L<C-W>p<C-W>J<C-w>p
  autocmd FileType qf nnoremap <buffer> t <C-W><CR><C-W>T
augroup END
" }}}

" Markdown config {{{
" Syntax highlight within fenced code blocks
let g:markdown_fenced_languages = ['bash=sh', 'css', 'html', 'js=javascript',
      \ 'less', 'typescript=javascript', 'python', 'sh']
" }}}

" Netrw config {{{
" Disable annoying banner
let g:netrw_banner=0

" Open in same window
let g:netrw_browse_split=0

" Open splits to the right
let g:netrw_altv=1

" Tree view
let g:netrw_liststyle=3

" Sensible limit to the width of the file explorer
let g:netrw_winsize = 25

" Hide files in .gitignore
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'
" }}}

" Local Settings {{{
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
" }}}
