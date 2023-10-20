" already set, skip
if did_filetype()
  finish
endif

" Detect deno shebang scripts
if getline(1) =~ '^#!.*\<deno\>'
  setf typescript
endif
