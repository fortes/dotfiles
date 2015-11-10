" vim:fdm=marker et fdl=2 ft=vim sts=2 sw=2 ts=2

" Plugins {{{
if !filereadable(expand('~/.config/nvim/autoload/plug.vim'))
  echo 'Must install vim-plug, run ~/dotfiles/scripts/nvim-setup.sh'
  echo 'Run nvim -u NONE to open without ' . expand("<sfile>")
  exit
endif

call plug#begin()

" Colors {{{
Plug 'w0ng/vim-hybrid'
" Temporary while developing colorscheme
" Plug 'fortes/vim-escuro'
" Plug '~/x/vim-escuro'
" Shades indent levels
Plug 'nathanaelkane/vim-indent-guides'
" }}}

" Editing {{{
" Auto-close parens / quotes, requires no config
Plug 'cohama/lexima.vim'
" Motion via two-character combinations
" s{char}{char} to move forward to instance of {char}{char}
" ; for next match
" <c-o> or `` to go back to starting point
" s<CR> to repeat last search
" S to search backwards
" For text objects, use z (s taken by surround.vim)
" {action}z{char}{char}
Plug 'justinmk/vim-sneak'
" Snippet support, see configuration below
Plug 'SirVer/ultisnips'
" Comment / uncomment things quickly
" {Visual}gc comment / uncomment selection
" - gc{motion} comment / uncomment lines for motion
Plug 'tpope/vim-commentary'
" Make plugin actions for a few plugins repeatable
Plug 'tpope/vim-repeat'
" Readline-style keybindings everywhere (e.g. <C-a> for beginning of line)
Plug 'tpope/vim-rsi'
" Needed for orgmode
" Makes <C-a> and <C-x> able to increment/decrement dates
Plug 'tpope/vim-speeddating'
" Edit surrounding quotes / parents / etc
" - {Visual}S<arg> surrounds selection
" - cs/ds<arg1><arg2> change / delete
" - ys<obj><arg> surrounds text object
" - yss<arg> for entire line
Plug 'tpope/vim-surround'
" Extra motion commands, including:
" - [f, ]f next/prev file in directory
" - [n, ]n next/prev SCM conflict
" Toggles a few options:
" - coh hlsearch
" - con number
" - cos spell
" - cow wrap
" Additonal paste options
" - >p paste and indent
" - <p paste and deindent
Plug 'tpope/vim-unimpaired'
" }}}

" File/Buffer Handling {{{
" Cd into the root of of the project with :ProjectRootCD
Plug 'dbakker/vim-projectroot'
if executable('fzf')
  " Use FZF for fuzzy finding if available (see config below)
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
else
  " Fuzzy finder, see config below for more
  " <C-p> start fuzzy finder
  " <C-d> toggle between full path and filename search
  " <C-r> Toggle between string and regex mode
  " <C-f>/<C-b> to change search modes
  " <C-s>/<C-v> open in split / vertical split
  " <C-t> open in tab
  " <tab> autocomplete directory
  Plug 'ctrlpvim/ctrlp.vim'
end
" Adds helpers for UNIX shell commands
" :Remove Delete buffer and file at same time
" :Unlink Delete file, keep buffer
" :Move Rename buffer and file
Plug 'tpope/vim-eunuch'
" Make netrw better
" - '-' in any buffer to go up to directory listing
" - cg/cl to cd into the 
" - ! to use the file in a command
Plug 'tpope/vim-vinegar'
" Show register contents when using " or @ in normal mode
" Also shows when hitting <c-r> in insert mode
Plug 'junegunn/vim-peekaboo'
" }}}

" General coding {{{
Plug 'fortes/vim-personal-snippets'
" Temporary while editing
"Plug '~/x/vim-personal-snippets/'
" async :make via NeoVim job control, replaces syntastic for showing errors
" Provides :Neomake and :Neomake!
" Only load on first use of :Neomake command
Plug 'benekastah/neomake', {
\   'on': ['Neomake']
\ }
" Use SignColumn to mark lines in Quickfix/Location list
Plug 'dhruvasagar/vim-markify'
" Test.vim: Run tests based on cursor position / file
Plug 'janko-m/vim-test', {
\   'for': ['javascript']
\ }
" }}}

" Git {{{
" Run Git commands from within Vim
" :Gstatus show `git status` in preview window
" - <C-N>/<C-P> next/prev file
" - - add/reset file under cursor
" - ca :Gcommit --amend
" - cc :Gcommit
" - D :Gdiff
" - p :Git add --patch (reset on staged files)
" - q close status
" - r reload status
" :Gcommit for committing
" :Gblame run blame on current file
" - <cr> open commit
" - o/O open commit in split/tab
" - - reblame commit
Plug 'tpope/vim-fugitive'
" Adds gutter signs and highlights based on git diff
" [c ]c to jump to prev/next change hunks
" <leader>hs to stage hunks within cursor
" <leader>hr to revert hunks within cursor
" <leader>hv to preview the hunk
Plug 'airblade/vim-gitgutter'
" }}}

" CSS/LESS {{{
" Better CSS syntax
Plug 'JulesWang/css.vim', {
\   'for': ['css', 'less']
\ }
" LESS Support
Plug 'groenewege/vim-less', {
\ 'for': ['less']
\ }
" }}}

" Javascript {{{
" JS syntax, supports ES6
Plug 'othree/yajs.vim', {
\   'for': ['javascript']
\ }
" Better indentation
Plug 'gavocanov/vim-js-indent', {
\   'for': ['javascript']
\ }
" JS syntax for common libraries
Plug 'othree/javascript-libraries-syntax.vim', {
\   'for': ['javascript']
\ }
" Tern auto-completion engine for JS (requires node/npm)
if executable('node')
  Plug 'marijnh/tern_for_vim', {
\     'do': 'npm install',
\     'for': ['javascript', 'coffee']
\   }
endif
" Makes gf work on node require statements
Plug 'moll/vim-node', {
\   'for': ['javascript']
\ }
" }}}
call plug#end()
" }}}

" Load Vanilla (no-plugin) config
if filereadable(expand("~/.vimrc"))
  source ~/.vimrc
endif

" Neovim-only config {{{
" Useful reference for Neovim-only features (:help vim-differences)

" Terminal {{{
" Quickly open a shell below current window
nnoremap <leader>sh :below 10sp term://$SHELL<cr>

" Send selection to term below
vnoremap <leader>sp :<C-u>norm! gv"sy<cr><c-w>j<c-\><c-n>pa<cr><c-\><c-n><c-w>k

" Terminal key bindings for window switching
" Map jj and jk to <ESC> to leave insert mode quickly
" Also allow <leader><C-c> and <leader><esc>
tnoremap jj <C-\><C-n>
tnoremap jk <C-\><C-n>
tnoremap <leader><C-c> <C-\><C-n>
tnoremap <leader><esc> <C-\><C-n>

" Automatically go into insert mode when entering terminal window
augroup terminal_insert
  autocmd!
  autocmd BufEnter * if &buftype == 'terminal' | :startinsert | endif
augroup END
" }}}

" Our setup makes sure to properly install the neovim python helper. Skip checks
" for better startup speed
let g:python_host_skip_check = 1
" Don't have Python3 installed, disable checking altogether for startup perf
let g:loaded_python3_provider = 1
" }}}

if &t_Co >= 256
  " Upgrade colors if we have more colors, stays with default if not available
  " silent! colorscheme escuro
  silent! colorscheme hybrid
endif

" TODO: Move into .vimrc
augroup on_vim_enter
  autocmd!
  autocmd VimEnter * call OnVimEnter()
augroup END

" Called after plugins have loaded {{{
function! g:OnVimEnter()
  augroup neomake_configuration
    autocmd!
    if exists(':Neomake')
      " Check for lint errors on open & write for supported filetypes
      autocmd BufRead,BufWritePost *.js,*.es6,*.less silent! Neomake!
    endif
  augroup END

  if exists(':ProjectRootCD')
    " Search across entire project when possible. Use quickfix by default since
    " linters will clobber the search results otherwise.
    nnoremap K :ProjectRootCD<cr>:silent! grep! "<C-R><C-W>"<cr>
    vnoremap K :<C-u>norm! gv"sy<cr>:ProjectRootCD<cr>:silent! grep! "<C-R>s"<cr>
    nnoremap Q :ProjectRootCD<cr>:grep!<SPACE>
  endif
endfunction
" }}}

" Plugin Configuration {{{
" Markify {{{
" Use nicer symbols
let g:markify_error_text = '✗'
let g:markify_warning_text = '⚠'
let g:markify_info_text = 'ℹ'

" Clear out markify symbols with <c-l>
nnoremap <silent> <C-L> :MarkifyClear<cr>:nohlsearch<cr><C-L>
" }}}

" Test.vim {{{
" Run test commands in NeoVim terminal
let test#strategy = 'neovim'

" Use dot reporter by default
let test#javascript#mocha#options = '--reporter dot'
" With autochdir, the default regex for tests fails, so just count on `_test.js`
let test#javascript#mocha#file_pattern = '_test.js'

" Only works in JS for now
augroup test_shortcuts
  autocmd!

  " <leader>tt to test based on cursor, <leader>twt to watch
  autocmd FileType javascript nnoremap <buffer> <silent> <leader>tt :split<cr>:TestNearest<cr>
  autocmd FileType javascript nnoremap <buffer> <silent> <leader>twt :split<cr>:TestNearest -w<cr><c-\><c-n><c-w><c-k>
  " <leader>tf to test current file, <leader> twf to watch
  autocmd FileType javascript nnoremap <buffer> <silent> <leader>tf :split<cr>:TestFile<cr>
  autocmd FileType javascript nnoremap <buffer> <silent> <leader>twf :split<cr>:TestFile -w<cr><c-\><c-n><c-w><c-k>
augroup END
" }}}

" NeoMake {{{
if executable('eslint') || executable('eslint_d')
  " Use eslint/eslint_d if it's available
  let g:neomake_javascript_enabled_makers = ['makeprg']
endif

if executable('lessc')
  let g:neomake_less_enabled_makers = ['makeprg']
endif
" }}}

" Fuzzy Finding (FZF/CtrlP) {{{
if executable('fzf')
  " FZF {{{
  " <C-p> or <C-t> to search files
  nnoremap <silent> <C-t> :FZF -m<cr>
  nnoremap <silent> <C-p> :FZF -m<cr>

  " <M-p> for open buffers
  nnoremap <silent> <M-p> :Buffers<cr>

  " <M-S-p> for MRU
  nnoremap <silent> <M-S-p> :History<cr>

  " Use fuzzy completion relative filepaths across directory with <c-x><c-j>
  imap <expr> <c-x><c-j> fzf#vim#complete#path('git ls-files $(git rev-parse --show-toplevel)')

  " Better command history with q:
  command! CmdHist call fzf#vim#command_history({'right': '40'})
  nnoremap q: :CmdHist<CR>

  " Better search history
  command! QHist call fzf#vim#search_history({'right': '40'})
  nnoremap q/ :QHist<CR>

  command! -bang -nargs=* Ack call fzf#vim#ag(<q-args>, {'down': '40%', 'options': --no-color'})
  " }}}
else
  " CtrlP {{{
  " <C-p> to search files
  let g:ctrlp_map='<C-p>'
  let g:ctrlp_cmd='CtrlP'

  " Don't jump to a window that is already open, but do jump to tabs
  let g:ctrlp_switch_buffer = 't'

  " <M-p> for just Buffers
  nnoremap <silent> <M-p> :CtrlPBuffer<cr>

  " <M-S-p> for MRU
  nnoremap <silent> <M-S-p> :CtrlPMRU<cr>

  " Keep more files in MRU
  let g:ctrlp_mruf_max = 100

  " Use ag for listing files
  if executable('ag')
    " Use git ls-files if possible for listing files, else fallback to ag
    let g:ctrlp_user_command= {
    \ 'types': {
    \   1: ['.git', 'git --git-dir=%s/.git ls-files -co --exclude-standard']
    \ },
    \ 'fallback': 'ag %s -l --nocolor -g ""'
    \ }

    " git ls-files & ag are fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching=0
  endif
  " }}}
end
" }}}

" UltiSnips {{{
" Use tab to expand snippet and move to next target. Shift tab goes back.
" <C-k> lists available snippets for the file
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<C-k>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
" }}}

" Autopairs {{{
" Remove default mapping to toggle autopairs and use Unimpaired-style
" toggling
let g:AutoPairsShortcutToggle='coa'
" }}}

" Tern {{{
let g:tern_show_signature_in_pum=1
let g:tern_show_argument_hints=1

augroup tern_shortcuts
  autocmd!

  " <leader>tr to rename variable under cursor via Tern
  autocmd FileType javascript nnoremap <buffer> <leader>tr :TernRename<cr>
  " <leader>td to go to definition
  autocmd FileType javascript nnoremap <buffer> <leader>td :TernDef<cr>
augroup END
" }}}

" GitGutter {{{
" Unimpaired-style toggling for the line highlights
" cogg Gutter / cogl line highlight
nnoremap <silent> cogg :GitGutterToggle<cr>
nnoremap <silent> cogl :GitGutterLineHighlightsToggle<cr>

" Ignore whitespace
let g:gitgutter_diff_args='-w'

" Use raw grep
let g:gitgutter_escape_grep=1

" Use highlighting as well as signs
let g:gitgutter_highlight_lines=1

" Be aggressive about looking for diffs
let g:gitgutter_realtime=1
let g:gitgutter_eager=1

" Tweak signs
let g:gitgutter_sign_modified='±'
let g:gitgutter_sign_modified_removed='≠'
" }}}

" Indent Guides {{{
" Default guides to on everywhere
let g:indent_guides_enable_on_vim_startup=1

" Don't turn on mapping for toggling guides
let g:indent_guides_default_mapping=0

" Don't use their colors, depending on the colorscheme to define
let g:indent_guides_auto_colors=0

" Wait until we've nested a little before showing
let g:indent_guides_start_level=3

" Skinny guides
let g:indent_guides_guide_size=1
" }}}

" Javascript libraries syntax {{{
let g:used_javascript_libs='react'
" }}}
" }}}

" Local Settings {{{
if filereadable(expand("~/.nvimrc.local"))
  source ~/.nvimrc.local
endif
" }}}
