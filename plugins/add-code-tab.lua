code_snippets = HTML.select(page, "code.language-ocaml")

data = config
tab_tmpl =
  "<div class=\"tab\">" ..
  "<a class=\"button-language-ocaml tablinks\" href=\"#\" onclick=\"openLangTab(event, 'language-ocaml')\"><code>ml</code></a>" ..
  "<a class=\"button-language-reason tablinks\" href=\"#\" onclick=\"openLangTab(event, 'language-reason')\"><code>re</code></a>" ..
  "<a class=\"tablinks\" href=\"#\" onclick=\"openLangTab(event, 'output-language-javascript')\"><code>js</code></a>" ..
  "</div>"

index = 1
while code_snippets[index] do
  code_snippet = code_snippets[index]
  pre_container = HTML.parent(code_snippet)
  tab = String.render_template(tab_tmpl, data)
  HTML.insert_before(pre_container, HTML.parse(tab))
  index = index + 1
end