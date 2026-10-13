" already set, skip
if did_filetype()
  finish
endif

" Detect bun shebang scripts
if getline(1) =~ '^#!.*\<bun\>'
  setf typescript
endif
