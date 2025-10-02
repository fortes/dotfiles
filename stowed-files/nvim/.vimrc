" vim:fdm=marker et fdl=3 ft=vim sts=2 sw=2 ts=2

" Configuration for vanilla (neo)vim, with no plugins

" Neovim-vim deltas {{{
if !has('nvim')
  " Default vaules (or removed) in Neovim (see :help vim-differences). Make sure
  " we're working with the same baseline here.

  set autoindent
  set autoread
  set background=dark
  set backspace=indent,eol,start
  set belloff=all
  " vint: -ProhibitSetNoCompatible
  set nocompatible
  " vint: +ProhibitSetNoCompatible
  set complete-=i
  set cscopeverbose
  set display=lastline
  set encoding=utf-8
  set fillchars="vert:│,fold:·,foldsep:│"
  set formatoptions=tcq
  if v:version >= 704
    set formatoptions+=j
  endif
  set nofsync
  set hidden
  set history=10000
  set hlsearch
  set include=.
  set incsearch
  set nojoinspaces
  if has('&jumpoptions')
    set jumpoptions=clean
  endif
  if has('langmap') && (v:version > 704 || v:version == 704 && has('patch502'))
    set langnoremap
  endif
  set laststatus=2
  set mouse=nvi
  set mousemodel=popup_setpos
  set nrformats=bin,hex
  set path=".,,"
  set ruler
  set sessionoptions-=options
  set sessionoptions+=unix,slash
  set shortmess-=S
  set shortmess+=CF
  set showcmd
  set sidescroll=1
  set smarttab
  set nostartofline
  set switchbuf=uselast
  set tabpagemax=50
  set tags="./tags;,tags"
  set ttimeout
  set ttimeoutlen=50
  set ttyfast
  set viewoptions+=unix,slash
  set viewoptions-=options
  set wildmenu
  " nvim also sets `pum`, which doesn't exist in vim 8.2 on Mac
  set wildoptions=tagfile

  nnoremap Y y$
  nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
  inoremap <C-U> <C-G>u<C-U>
  inoremap <C-W> <C-G>u<C-W>

  " Enable syntax highlighting by default
  if has('syntax')
    syntax enable
  endif
endif
" }}}

" Base Configuration {{{

scriptencoding utf-8

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &runtimepath) ==# ''
  runtime! macros/matchit.vim
endif

" Use `:Cfilter` / `:Lfilter` to filter quickfix / location lists
" Useful with `:colder` and `:cnewer` to restore previous lists
if has('packages')
  packadd cfilter
endif

" Core Behavior {{{
if exists('+modelineexpr')
  set nomodelineexpr
else
  " Disable for security reasons when `modelineexpr` does not exist
  set nomodeline
endif

" Read .vimrc from current dir, if present
set exrc

" Don't allow shell and write commands in exrc
set secure

" Enable loading plugin / indent settings based on filetype, not supported
" in vim-tiny
if has('eval')
  filetype plugin indent on
endif

" Don't redraw while executing macros, etc
set lazyredraw

" Wait just under a second before CursorHold is fired
set updatetime=750

" Mapping & keycode timeouts
set timeoutlen=600
set ttimeout
set ttimeoutlen=200

if isdirectory(expand('~/.local/venv'))
  " Always use python3 from env that has `neovim` package
  let g:python3_host_prog = '~/.local/venv/bin/python3'
endif
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
set foldlevel=99
set foldlevelstart=99

" Limit folds when using indent or syntax
set foldnestmax=5

set foldopen+=jump

" Style for floating windows
if exists('+winborder')
  set winborder=rounded
endif
" }}}

" Enable live substitution
if exists('&inccommand')
  set inccommand=split
endif

" TODO: Feature check
augroup HighlightedYank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {on_visual=false}
augroup END

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

" Hide the intro screen, use [+] instead of [Modified], use [RO] instead
" of [readyonly], and don't give completion match messages
set shortmess+=Imrc

" Always show the signcolumn to avoid jitter, but show if multiple (only
" supported in neovim)
if has('nvim')
  set signcolumn=auto:1-3
endif

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

" Don't use backup files, we have Git for that
set nobackup
set noswapfile
set nowritebackup

" Search within subfolders by default
set path+=**
" But ignore noise
set path-=.git,build,node_modules,public,_site,third_party

" Ignore autogenerated files
set wildignore+=*.o,*.obj,*.pyc
" Ignore source control
set wildignore+=.git
set wildignore+=build,node_modules,public,_site,third_party
" Ignore images and fonts
set wildignore+=*.gif,*.jpg,*.jpeg,*.otf,*.png,*.svg,*.ttf
" Ignore case when completing
set wildignorecase
" }}}

" Status line {{{
if has('statusline')
  " Show git repo information (if available)
  let g:activeStatusLine='%{StatuslineTag()}»'
  " Relative path to file in current buffer
  let g:activeStatusLine.='%<%f '
  " Exclamation mark if not modifiable, + if modified
  let g:activeStatusLine.="%{&readonly ? \"! \" : &modified ? '+ ' : ''}"
  " Start left align, show filetype
  let g:activeStatusLine.="%= %{&filetype == '' ? 'none' : &filetype} "
  " Line/col/percent
  let g:activeStatusLine.='%l:%2c '
  function! StatuslineTag()
    if exists('g:loaded_fugitive')
      " Shitty unicode character w/o patched fonts
      return '‡'.FugitiveHead()
    else
      return fnamemodify(getwinvar(0, 'getcwd', getcwd()), ':t')
    endif
  endfunction

  let g:quickfixStatusLine='%t (%l of %L)'
  let g:quickfixStatusLine.='%{exists("w:quickfix_title")? " ".w:quickfix_title : ""}'
  let g:quickfixStatusLine.='%=%-15(%l,%c%V%) %P'

  " Default status line
  let statusline=g:activeStatusLine

  " Use different status line for active vs. inactive buffers
  function! UpdateStatusLine(status)
    if &filetype==?'qf'
      let &l:statusline=g:quickfixStatusLine
    elseif &filetype==?'help' || &filetype==?'netrw'
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
endif
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
" Keyword completion brings in the dictionary if spell check is enabled.
" Also included files
set complete+=kspell,i
if has ('nvim-0.11')
  " Also include buffer names, if supported
  set complete+=f
endif

" Show menu even when only one match, don't autoselect, and show match info
" in popup
set completeopt=menuone,noselect,popup

if has('nvim-0.11')
  " Fuzzy completion added in 0.11
  " TODO: Figure out how to check if fuzzy is available without version checker
  set completeopt+=fuzzy
endif

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
set listchars=trail:·,tab:→-,nbsp:␣
" Show wrap indicators
set listchars+=extends:»,precedes:«
" Indent guides
set listchars+=multispace:\ ·,leadmultispace:\┊\ ,
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
if !exists('g:colors_name')
  " Base install has some lame themes, this one is OK, I guess
  silent! colorscheme desert
endif

if has('termguicolors')
  " Mac doesn't ship with tmux terminfo
  if $COLORTERM == 'truecolor' || $TERM =~ '^\(xterm\|tmux\)-256'
    set termguicolors
  endif
endif

" Only highlight first 500 chars for better performance
set synmaxcol=500
" }}}

" Searching {{{
" Match all results in a line by default (/g at end will undo this)
set gdefault

" Ignore case, except when using some uppercase
set ignorecase
set smartcase

" `vim.tiny` doesn't support scripting
if has('eval')
  " Shows marks in quickfix list
  function! s:Cmarks() abort
    let items = []

    " Global marks:
    let marklist = getmarklist()
    " Local marks:
    let marklist += getmarklist(bufnr())

    for mark in marklist
      let name = mark.mark[1]
      if name !~ '[a-zA-Z]'
        continue
      endif

      if has_key(mark, 'file')
        let filename = fnamemodify(mark.file, ':p')
      else
        let filename = expand('%:p')
      endif

      if !filereadable(filename)
        " A mark could have been saved in a temporary file
        continue
      endif

      let [buffer, line, col, _] = mark.pos
      let text = readfile(filename)[line - 1]

      call add(items, { 'filename': filename, 'buffer': buffer, 'text': name..' | '..text, 'lnum': line, 'col': col || 1 })
    endfor

    call setqflist([], 'r', {'title': 'Marks', 'items': items})
    copen
  endfunction

  " Show marks in quickfix list
  command! Cmarks call s:Cmarks()
  nnoremap <m-m> :Cmarks<cr>

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

  function! IsInsideGitRepo()
    let result=systemlist('git rev-parse --is-inside-work-tree')
    if v:shell_error
      return 0
    else
      return 1
    endif
  endfunction

  function! FindGitRootCD()
    let root = systemlist('git -C ' . expand('%:p:h') . ' rev-parse --show-toplevel')[0]
    if v:shell_error
      return ''
    else
      return {'dir': root}
    endif
  endfunction

  function! GetSearchPath()
    let result = FindGitRootCD()
    if type(result) == type({})
      let repo_root = result['dir']
      if getcwd() == repo_root
        return '.'
      else
        return fnamemodify(repo_root, ':~:.')
      endif
    else
      return '.'
    endif
  endfunction

  " Change to git root of current file (if in a repo)
  function! GitRootCD()
    let result = FindGitRootCD()
    if type(result) == type({})
      execute 'tcd' fnameescape(result['dir'])
      echo 'Now in '.fnamemodify(result['dir'], ':~:.')
    else
      echo 'Not in git repo!'
    endif
  endfunction
  command! GitRootCD :call GitRootCD()

  " No Ex-mode, start project search instead, using word under the cursor
  nnoremap Q :lgrep! "<C-R><C-W>" <C-R>=GetSearchPath()<CR>
  vnoremap Q :<C-u>norm! gv"sy<cr>:lgrep! "<C-R>s" <C-R>=GetSearchPath()<CR>
endif

" Automatically open quickfix/location list after grep/make
augroup auto_quickfix
  autocmd!
  " Make sure to redraw to avoid strange render bugs
  autocmd QuickFixCmdPost lgrep lwindow|redraw!
  autocmd QuickFixCmdPost grep,make cwindow|redraw!
augroup END

" Use ag instead of grep, if available
if executable('rg')
  " Use smart case, match whole words, use literal string, and output in
  " vim-friendly format
  set grepprg=rg\ --vimgrep
else
  " Mimic rg settings (literal, recursive, ignore common directories)
  set grepprg=grep\ --with-filename\ --fixed-strings\ --binary-files=without-match\ --ignore-case\ --line-number\ --recursive\ --exclude-dir=socket\ --exclude-dir=.git\ --exclude-dir=node_modules\ $*\ /dev/null
  set grepformat=%f:%l:%m
endif
" }}}

" Efficiency Shortcuts {{{

if has('eval')
  " Use space as leader
  let mapleader=' '
  let maplocalleader=' '
endif

" Use enter as colon for faster commands
nnoremap <cr> :
vnoremap <cr> :
" Meta-enter in case you need an actual <cr>
nnoremap <M-cr> <cr>
vnoremap <M-cr> <cr>

" Close quickfix & help with q, Escape, or Control-C
" Also, keep default <cr> binding
augroup easy_close
  autocmd!
  autocmd FileType help,qf,lspinfo,dirvish nnoremap <buffer> q :q<cr>
  autocmd FileType help,qf,lspinfo,dirvish nnoremap <buffer> <Esc> :q<cr>
  autocmd FileType help,qf,lspinfo,dirvish nnoremap <buffer> <C-c> :q<cr>
  " Undo <cr> -> : shortcut
  autocmd FileType help,qf,lspinfo,dirvish nnoremap <buffer> <cr> <cr>
augroup END

" Make j/k move screen visible lines, not file lines
nnoremap j gj
nnoremap k gk

" CTRL-U for undo in insert mode
inoremap <C-U> <C-G>u<C-U>

" Never use ZZ, too dangerous
nnoremap ZZ <nop>

" Run `.` or macro over selected lines, taken from:
" https://reddit.com/r/vim/comments/3y2mgt
vnoremap . :normal .<CR>
vnoremap @ :normal @

" Change local directory to current file
nnoremap <leader>lcd :tcd %:p:h<cr>
" Go back to root
nnoremap <leader>cd :GitRootCD<cr>

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
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.json,*.conf,*.ini,*.pug setlocal textwidth=0

  " Enable spell checking & linebreaking at words in some filetypes
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.markdown,COMMIT_EDITMSG setlocal spell linebreak

  " Disable spell checking on unmodifiable files (what's the point?)
  autocmd BufReadPost * if !&modifiable | setlocal nospell | endif

  " Set up linting for JS
  if executable('eslint')
    autocmd FileType javascript setlocal makeprg=eslint\ -f\ compact\ %

    " Parse eslint errors correctly
    autocmd FileType javascript setlocal errorformat=%E%f:\ line\ %l\\,\ col\ %c\\,\ Error\ -\ %m
    autocmd FileType javascript setlocal errorformat+=%W%f:\ line\ %l\\,\ col\ %c\\,\ Warning\ -\ %m
    " Ignore lines that don't match the above
    autocmd FileType javascript setlocal errorformat+=%-G%.%#
  endif

  " TypeScript type checking
  if executable('tsc')
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
    autocmd FileType less setlocal makeprg=lessc\ --lint\ --no-color\ %
    autocmd FileType less setlocal errorformat=%E%.%#Error:\ %m\ in\ %f\ on\ line\ %l\\,\ column\ %c:
    " Ignore unmatched lines
    autocmd FileType less setlocal errorformat+=%-G%.%#
  endif

  " CSS linting
  if executable('stylelint')
    autocmd FileType css setlocal makeprg=stylelint\ %\ --no-color\ --fix\ --cache
    " Push/pop filename on stack with %P%f
    autocmd FileType css setlocal errorformat+=%P%f,%*[\ ]%l:%c%*[\ ]✖%*[\ ]%m
    " Ignore unmatched lines
    autocmd FileType css setlocal errorformat+=%-G%.%#
  endif

  " Linting for shell scripts
  if executable('shellcheck')
    autocmd FileType sh setlocal makeprg=shellcheck\ -x\ -f\ gcc\ %
  endif

  " Linting for prose
  if executable('proselint')
    autocmd FileType markdown,text setlocal makeprg=proselint\ %
  endif

  " Linting for vimscript
  if executable('vint')
    autocmd FileType vim setlocal makeprg=vint\ --enable-neovim\ \-s\ %
  endif

  if executable('shfmt')
    autocmd FileType sh setlocal formatprg=shfmt\ --indent\ 2
  endif

  " Use prettier to autoformat (gq in Visual mode)
  if executable('prettier')
    autocmd FileType javascript setlocal formatprg=prettier

    autocmd FileType typescript,typescript.tsx setlocal formatprg=prettier\ --parser\ typescript

    autocmd FileType json setlocal formatprg=prettier\ --parser\ json

    autocmd FileType css,less setlocal formatprg=prettier\ --parser\ css

    autocmd FileType html setlocal formatprg=prettier\ --parser\ html

    autocmd FileType markdown setlocal formatprg=prettier\ --parser\ markdown

    autocmd FileType yaml setlocal formatprg=prettier\ --parser\ yaml

    " Use `formatprg` for `formatexpr` wherever we use `prettier`
    autocmd FileType javascript setlocal formatexpr=
    autocmd FileType typescript,typescript.tsx setlocal formatexpr=
    autocmd FileType json setlocal formatexpr=
    autocmd FileType css,less setlocal formatexpr=
    autocmd FileType html setlocal formatexpr=
    autocmd FileType markdown setlocal formatexpr=
    autocmd FileType yaml setlocal formatexpr=
  endif

  if executable('ruff')
    autocmd FileType python setlocal formatprg=ruff\ format\ --stdin-filename\ %\ -
  endif

  " Find .js files when using `gf` (useful with require)
  autocmd FileType javascript setlocal suffixesadd=.js,.json,index.js
  autocmd FileType typescript setlocal suffixesadd=.ts,.tsx,.js,.jsx,.json,index.js,index.ts

  autocmd FileType markdown setlocal suffixesadd=.md,index.md

  " Consider '-' part of a world when tab completion, etc in css/less
  autocmd FileType css,less setlocal iskeyword+=-

  " Don't wrap in commit messages
  autocmd FileType gitcommit setlocal nowrap textwidth=0

  " Makefiles use tabs
  autocmd FileType make setlocal noexpandtab shiftwidth=4

  " Python uses 4 spaces
  autocmd FileType python setlocal shiftwidth=4

  " Don't wrap in quickfix, and don't show in buffer list
  autocmd FileType qf setlocal nowrap textwidth=0 nobuflisted
augroup END
" }}}

" Markdown config {{{
if has('syntax')
  " Syntax highlight within fenced code blocks
  let g:markdown_fenced_languages = ['bash=sh', 'css', 'html', 'js=javascript', 'less', 'ts=typescript', 'python', 'sh']
endif
" }}}

if has('spell')
  set spell
  set spelllang=en_us,pt_pt

  let s:spell_dir = fnamemodify($MYVIMRC, ':h').'/spell'
  let s:spell_file = (s:spell_dir).'/pt.utf-8.spl'
  let s:spell_url = 'https://ftp.nluug.nl/vim/runtime/spell/pt.utf-8.spl'

  " Download Portuguese dictionary if not present, but only if the directory
  " is already present, else we might be using a temporary config file anyway
  if isdirectory(s:spell_dir) && !filereadable(s:spell_file)
    echo "Portuguese spell file not found. Downloading..."
    if executable('curl')
      execute '!curl -fLo ' . s:spell_file . ' ' . s:spell_url
    elseif executable('wget')
      execute '!wget -O ' . s:spell_file . ' ' . s:spell_url
    endif
  endif

  " Re-generate spelling files if modified
  for d in glob(fnamemodify($MYVIMRC, ':h').'/spell/*.add', 1, 1)
    if getftime(d) > getftime(d.'.spl')
      exec 'mkspell! ' . fnameescape(d)
    endif
  endfor
endif

" Disable things we don't care about
let g:loaded_perl_provider = 0
let g:loaded_ruby_provider = 0

" Local Settings {{{
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
" }}}
