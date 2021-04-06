-- Inserts a menu for navigating between chapters

chapters = JSON.from_string(Sys.read_file(config["data_file"]))

local n = 1
local count = size(chapters)

current_chapter = 0

-- Finds the number of the current chapter, based on the file name.
-- If the page file name matches the chapter id, we are there.
while (n <= count) do
  if Regex.match(page_file, "/" .. chapters[n]["id"]) then
    Log.warning(chapters[n]["id"])
    current_chapter = n

    -- No break in Lua-ML, need to fix that...
    -- Emulate break by fast-forwarding the counter
    n = count + 1
  else
    n = n + 1
  end
end

nav_tmpl =
  "<li><a href=\"/{{prev.id}}\">Previous</a></li>" ..
  "<li><a href=\"/\">Top</a></li>" ..
  "<li><a href=\"/{{next.id}}\">Next</a></li>"

env = {}
env["prev"] = chapters[current_chapter - 1]
env["next"] = chapters[current_chapter + 1]

nav_bar = String.render_template(nav_tmpl, env)


container = HTML.select_one(page, ".chapters-navigation")
HTML.prepend_child(container, HTML.parse(nav_bar))
