" vim:fdm=marker et ft=vim sts=2 sw=2 ts=2

" Automatically download vim-plug, if not present
if !filereadable(expand($XDG_CONFIG_HOME.'/nvim/autoload/plug.vim'))
  echo 'vim-plug not installed, downloading'
  !curl -fLo "$XDG_CONFIG_HOME/nvim/autoload/plug.vim" --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  echo 'vim-plug downloaded, will install plugins once vim loads'
  augroup VimPlugInstall
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
else
  " Clear out install on enter
  augroup VimPlugInstall
    autocmd!
  augroup END
endif

" Read ~/.vimrc as well
if filereadable(expand($HOME.'/.vimrc'))
  source $HOME/.vimrc
endif

" Plugins {{{
call plug#begin()

" Colors {{{
" A bunch of Base16 colorschemes
Plug 'chriskempson/base16-vim'
" Shades indent levels
Plug 'nathanaelkane/vim-indent-guides'
" }}}

" System {{{

" Editing {{{
" Accent autocompletion via gx in normal mode
Plug 'airblade/vim-accent'
" <leader>nr open visual selection in sep window
Plug 'chrisbra/NrrwRgn'
" Auto-close parens / quotes, requires no config
Plug 'cohama/lexima.vim'
" Shared project settings
Plug 'editorconfig/editorconfig-vim'
" Personal snippets
Plug 'fortes/vim-personal-snippets'
" Make it easier to find the cursor after searching
Plug 'inside/vim-search-pulse'
" Motion via two-character combinations
" s{char}{char} to move forward to instance of {char}{char}
" ; for next match
" <c-o> or `` to go back to starting point
" s<CR> to repeat last search
" S to search backwards
" For text objects, use z (s taken by surround.vim)
" {action}z{char}{char}
Plug 'justinmk/vim-sneak'
" Share clipboard with tmux
Plug 'cazador481/fakeclip.neovim'
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
" Replace object with register contents
" gr{motion} Replace w/ unnamed register
" "xgr{motion} Replace w/ register x
Plug 'vim-scripts/ReplaceWithRegister'
" Complete words from tmux with <C-x><C-u>
" Plug 'wellle/tmux-complete.vim'
" }}}

" File/Buffer Handling {{{
" Use FZF for fuzzy finding if available (see config below)
if executable('fzf')
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
end
" Show register contents when using " or @ in normal mode
" Also shows when hitting <c-r> in insert mode
Plug 'junegunn/vim-peekaboo'
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
" }}}

" General coding {{{
" async LanguageServerClient, lots of commands (rename, definitions, etc)
" No default bindings, see config below
Plug 'autozimu/LanguageClient-neovim', {
      \ 'branch': 'next',
      \ 'do': 'bash install.sh'
      \ }
" async :make via NeoVim job control, replaces syntastic for showing errors
" TODO: Use w0rp/ale instead of Neomake and adjust all settings for this
" https://github.com/w0rp/ale
" LanguageServer may remove the need for all of this in places, need to figure
" out what is really needed here.
" Test.vim: Run tests based on cursor position / file
Plug 'janko-m/vim-test', { 'for': ['javascript'] }
" Syntax highlighting and language server
Plug 'reasonml-editor/vim-reason-plus'
" Async completion
Plug 'ncm2/ncm2'
" Required by ncm2
Plug 'roxma/nvim-yarp'
" Completion sources
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-tmux'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-ultisnips'
" async code formatting
" :Neoformat <opt_formatter> for entire file
" :Neoformat! <filetype> for visual selection
Plug 'sbdchd/neoformat', { 'on': ['Neoformat'] }
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
Plug 'JulesWang/css.vim', { 'for': ['css', 'less'] }
" LESS Support
Plug 'groenewege/vim-less', { 'for': ['less'] }
" }}}

" Markdown {{{
" Nice set of markdown tools
" <leader>= /  <leader>- toggle checkboxes
" <leader>[ /  <leader>] change heading level
" <leader>' to make blockquote out of selection
" <leader>i to insert / update table of contents
Plug 'SidOfc/mkdx', { 'for': ['markdown'] }
" }}}

" Javascript {{{
" JS highlighting and indent support. Sometimes buggy, but has support for
" jsdocs and flow
Plug 'pangloss/vim-javascript', { 'for': ['javascript']}
" }}}

" Typescript {{{
" Highlighting and indent support
Plug 'leafgarland/typescript-vim', { 'for': ['typescript']}
" TODO: Get omnicompletion working well without a mess of plugins
" }}}

" Misc coding {{{
" Pug template support
Plug 'digitaltoad/vim-pug'
" }}}
call plug#end()
" }}}

" Load Vanilla (no-plugin) config
if filereadable(expand('~/.vimrc'))
  source ~/.vimrc
endif

" Re-generate spelling files if modified
for d in glob(fnamemodify($MYVIMRC, ':h').'/spell/*.add', 1, 1)
  if getftime(d) > getftime(d.'.spl')
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor

" Neovim-only config {{{
" Useful reference for Neovim-only features (:help vim-differences)

" Terminal {{{
" Lots of scrollback in terminal
let g:terminal_scrollback_buffer_size = 50000

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
" }}}

if &t_Co >= 256
  " Upgrade colors if we have more colors, stays with default if not available
  let base16colorspace=256
  silent! colorscheme base16-railscasts
endif

" TODO: Move into .vimrc
augroup on_vim_enter
  autocmd!
  autocmd VimEnter * call OnVimEnter()
augroup END

" Called after plugins have loaded {{{
function! g:OnVimEnter()
  augroup neoformat_autosave
    autocmd!
    if exists(':Neoformat')
      " Run automatically before saving for supported filetypes
      autocmd BufWritePre *.css,*.less,*.js,*.re,*.ts Neoformat
    endif
  augroup END
endfunction
" }}}

" Plugin Configuration {{{

" Enable tmux to be mapped to '+' register
let g:vim_fakeclip_tmux_plus=1

" LanguageClient-neovim {{{
" Don't need to automake in supported languages
augroup automake
  autocmd!
  " JavaScript and Typescript lint via language servers
  autocmd BufWritePost *.sh,*.less,*.css,*.vim,*.vimrc,*.txt,*.md make!
augroup END

" Use location list instead of quickfix
let g:LanguageClient_diagnosticsList = 'location'

augroup LanguageClientConfig
  autocmd!

  " <leader>ld to go to definition
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>ld :call LanguageClient_textDocument_definition()<cr>
  " <leader>li to go to implementation
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>li :call LanguageClient_textDocument_implementation()<cr>
  " <leader>lt to go to type definition
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>lt :call LanguageClient_textDocument_typeDefinition()<cr>
  " <leader>lf to autoformat document / selection
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>lf :call LanguageClient_textDocument_formatting()<cr>
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh vnoremap <buffer> <leader>lf :call LanguageClient_textDocument_rangeFomatting()<cr>
  " <leader>lh for type info under cursor
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>lh :call LanguageClient_textDocument_hover()<cr>
  " <leader>lr to rename variable under cursor
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>lr :call LanguageClient_textDocument_rename()<cr>
  " <leader>lc to find references
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>lc :call LanguageClient_textDocument_references()<cr>
  " <leader>ls to fuzzy find the symbols in the current document
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>ls :call LanguageClient_textDocument_documentSymbol()<cr>
  " <leader>lw to fuzzy find the symbols in entire workspace
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh nnoremap <buffer> <leader>lw :call LanguageClient_textDocument_workspace_symbol()<cr>

  " Use as omnifunc by default
  autocmd FileType javascript,python,typescript,json,css,less,html,reason,sh setlocal omnifunc=LanguageClient#complete
augroup END

let g:LanguageClient_serverCommands = {}

if executable('pyls')
  let g:LanguageClient_serverCommands.python = ['pyls']
endif

if executable('javascript-typescript-stdio')
  let g:LanguageClient_serverCommands.javascript = ['javascript-typescript-stdio']
  let g:LanguageClient_serverCommands.typescript = ['javascript-typescript-stdio']
  let g:LanguageClient_serverCommands.html = ['html-languageserver', '--stdio']
  let g:LanguageClient_serverCommands.css = ['css-languageserver', '--stdio']
  let g:LanguageClient_serverCommands.less = ['css-languageserver', '--stdio']
  let g:LanguageClient_serverCommands.json = ['json-languageserver', '--stdio']
endif

if executable('ocaml-language-server')
  let g:LanguageClient_serverCommands.reason = ['ocaml-language-server', '--stdio']
  let g:LanguageClient_serverCommands.ocaml = ['ocaml-language-server', '--stdio']
endif

if executable('bash-language-server')
  let g:LanguageClient_serverCommands.sh = ['bash-language-server', 'start']
endif
" }}}

" ncm2 {{{
" Enable in all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
" }}}

" Test.vim {{{
" Run test commands in NeoVim terminal
let test#strategy = 'neovim'

let test#javascript#mocha#options = {
  \ 'nearest': '--reporter list',
  \ 'file': '--reporter list',
  \ 'suite': '--reporter dot',
  \ }

" Only works in JS for now
augroup test_shortcuts
  autocmd!

  " <leader>tt to test based on cursor, <leader>twt to watch
  autocmd FileType javascript,typescript nnoremap <buffer> <silent> <leader>tt :TestNearest<cr>
  autocmd FileType javascript,typescript nnoremap <buffer> <silent> <leader>twt :TestNearest -w<cr><c-\><c-n><c-w><c-k>
  " <leader>tf to test current file, <leader> twf to watch
  autocmd FileType javascript nnoremap <buffer> <silent> <leader>tf :TestFile<cr>
  autocmd FileType javascript nnoremap <buffer> <silent> <leader>twf :TestFile -w<cr><c-\><c-n><c-w><c-k>
augroup END
" }}}

" Neoformat {{{
" Use formatprg when available
let g:neoformat_try_formatprg = 1
" }}}

" Fuzzy Finding (FZF) {{{
if executable('fzf')
  " <C-p> or <C-t> to search files
  " Open in split via control-x / control-v
  " Select/Deselect all via alt-a / alt-d
  onoremap <silent> <C-t> :call fzf#vim#files('', fzf#vim#with_preview())<cr>
  nnoremap <silent> <C-p> :call fzf#vim#files('', fzf#vim#with_preview())<cr>

  " <M-p> for open buffers
  nnoremap <silent> <M-p> :Buffers<cr>

  " <M-S-p> for MRU & v:oldfiles
  nnoremap <silent> <M-S-p> :History<cr>

  " Fuzzy insert mode completion for lines
  imap <c-x><c-l> <plug>(fzf-complete-line)

  " Use fuzzy completion relative filepaths across directory with <c-x><c-j>
  imap <expr> <c-x><c-j> fzf#vim#complete#path('git ls-files $(git rev-parse --show-toplevel)')

  " Better command history with <leader>:
  nnoremap <leader>: :History:<CR>

  " Better search history with <leader>/
  nnoremap <leader>/ :History/<CR>

  " Fuzzy search help <leader>?
  nnoremap <leader>? :Helptags<CR>

  " Search from git root via :Rag (Root Ag)
  " :Rag  - hidden preview enabled with "?" key
  " :Rag! - fullscreen and preview window above
  command! -bang -nargs=* Rag
    \ call GitRootCD() | call fzf#vim#ag(<q-args>,
    \                 <bang>0 ? fzf#vim#with_preview('up:60%', '?')
    \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
    \                 <bang>0)

  " Use fuzzy searching for K & Q, select items to go into quickfix
  nnoremap K :Rag! <C-R><C-W><cr>
  vnoremap K :<C-u>norm! gv"sy<cr>:silent! Rag! <C-R>s<cr>
  nnoremap Q :Rag!<SPACE>
end
" }}}

" UltiSnips {{{
" Use tab to expand snippet and move to next target. Shift tab goes back.
let g:UltiSnipsExpandTrigger='<tab>'
" <C-k> fuzzy-finds available snippets for the file with FZF
" let g:UltiSnipsListSnippets="<C-k>"
inoremap <C-k> <C-o>:Snippets<cr>
let g:UltiSnipsJumpForwardTrigger='<tab>'
let g:UltiSnipsJumpBackwardTrigger='<S-tab>'
" }}}

" vim-javascript {{{
" jsdoc syntax
let g:javascript_plugin_jsdoc = 1

" flow syntax
let g:javascript_plugin_flow = 1
" }}}

" vim-typescript {{{
" Have prettier to autoformat, so don't bother with indent rules.
let g:typescript_indent_disable = 1
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

" Don't highlight lines by default (use cogl to toggle)
let g:gitgutter_highlight_lines=0

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

" vim-jsx config {{{
" Don't require .jsx extension
let g:jsx_ext_required=0
" }}}

" }}}

" Local Settings {{{
if filereadable(expand('~/.nvimrc.local'))
  source ~/.nvimrc.local
endif
" }}}
