;; For now, gotmpl only used within html for Hugo, so hardcode here
((text) @injection.content
 (#set! injection.language "html")
 (#set! injection.combined))
