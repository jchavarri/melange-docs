pages = JSON.from_string(Sys.read_file(config["data_file"]))

container = HTML.select_one(page, "#pages-index")

local n = 1
local count = size(pages)
while (n <= count) do
  if not pages[n].nav_path[1] then
    li = HTML.parse(String.render_template("<li><a href=\"/{{url}}/\">{{title}}</a></li>", pages[n]))
    HTML.append_child(container, li)
  end

  n = n + 1
end
