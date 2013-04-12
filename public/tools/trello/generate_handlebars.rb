template = File.read('./handlebars/bin/templates.js')
str = "// Handlebars templates"
common = File.read('./public/tools/trello/board.js').split(str)[0] || ""
common += str + "\n" + `handlebars ./public/tools/trello/board.handlebars`
File.open('./public/tools/trello/board.js', 'w') do |f|
  f.puts common
end