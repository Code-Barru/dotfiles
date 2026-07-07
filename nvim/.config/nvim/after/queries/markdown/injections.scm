; extends

; Inject tsx for HTML blocks in MDX files
((html_block) @injection.content
  (#set! injection.language "tsx")
  (#set! injection.combined)
  (#set! injection.include-children))
