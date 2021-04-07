code_snippets = HTML.select(page, "code.language-ocaml")

data = config
tab_tmpl =
  "<div class=\"tab\">" ..
  "<button class=\"button-language-ocaml tablinks\" onclick=\"openLangTab(event, 'language-ocaml')\">ml</button>" ..
  "<button class=\"tablinks\" onclick=\"openLangTab(event, 'language-reason')\">re</button>" ..
  "<button class=\"tablinks\" onclick=\"openLangTab(event, 'output-language-javascript')\">output (js)</button>" ..
  "</div>"

index = 1
while code_snippets[index] do
  code_snippet = code_snippets[index]
  pre_container = HTML.parent(code_snippet)
  tab = String.render_template(tab_tmpl, data)
  HTML.insert_before(pre_container, HTML.parse(tab))
  index = index + 1
end