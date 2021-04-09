-- Inserts side nav bar content

pages = JSON.from_string(Sys.read_file(config["data_file"]))

container = HTML.select_one(page, "#site-nav > ul")

local n = 1
local count = size(pages)
while (n <= count) do
  local current_page = pages[n]
  if current_page.page_file == page_file then
    current_page.item_active = " active"
    current_page.link_active = " active"
  else
    current_page.item_active = ""
    current_page.link_active = ""
  end
  if Regex.match(current_page.page_file, "index.md") then
    local parent_page = current_page
    n = n + 1
    local inner_items = ""
    while (n <= count and pages[n].nav_path[1]) do
      local subitem_page = pages[n]
      if subitem_page.page_file == page_file then
        current_page.item_active = " active"
        subitem_page.active = " active"
      else
        subitem_page.active = ""
      end
      inner_items = inner_items .. "<li class=\"nav-list-item{{active}}\"><a href=\"{{url}}\" class=\"nav-list-link{{active}}\">{{title}}</a></li>"
      inner_items = String.render_template(inner_items, subitem_page)
      n = n + 1
    end
    n = n - 1
    with_children_item_tmpl = "<li class=\"nav-list-item{{item_active}}\">" ..
      "<a href=\"#\" class=\"nav-list-expander\">" ..
      "<svg viewBox=\"0 0 24 24\"><use xlink:href=\"#svg-arrow-right\"></use></svg></a>" ..
      "<a href=\"{{url}}\" class=\"nav-list-link{{link_active}}\">{{title}}</a>" ..
      "<ul class=\"nav-list \">" ..
      inner_items ..
      "</ul></li>"
      li = HTML.parse(String.render_template(with_children_item_tmpl, current_page))
      HTML.append_child(container, li)
  else
    simple_item_tmpl =
    "<li class=\"nav-list-item{{item_active}}\"><a href=\"{{url}}\" class=\"nav-list-link{{link_active}}\">{{title}}</a></li>"
    
    li = HTML.parse(String.render_template(simple_item_tmpl, current_page))
    HTML.append_child(container, li)
  end

  n = n + 1
end
    