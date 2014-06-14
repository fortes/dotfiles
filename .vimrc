" vim:fdm=marker ts=2 sts=2 sw=2 fdl=0

" NeoBundle {{{
if has('vim_starting')
  set nocompatible
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" Bundles {{{

call neobundle#end()
" }}}

filetype plugin indent on

" Prompt to install missing bundles
NeoBundleCheck
" }}}
