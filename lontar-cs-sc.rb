#!/usr/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pp'
require 'json'

##
# Main parse function, return array
# of entries in current uri
def parse_lontar(uri)
  puts "Downloading: #{uri}"
  page = Nokogiri::HTML(open(uri))

  # Start analyzing from third table.
  # If it is not exist, it means something
  # Going wrong and just return empty array
  tables = page.css('body table')
  res = []
  return [] if tables.length < 3
  puts "Got #{tables.length} entries"
  tables.each do |table|
    # Skip if there is nothing
    next unless table.css('.judulkoleksi a').length > 0

    title = table.css('.judulkoleksi a')[0].text
    link = table.css('.judulkoleksi a')[0]['href']
    datakoleksi_raw = table.css('.datakoleksi').last.text
    author_all = datakoleksi_raw.match(/Author: (.+);.*\|/)
    author_all = 
      if author_all.to_a.empty?
        ''
      else
        author_all[1]
      end
    year_raw = datakoleksi_raw.match(/(\d+).+\|.+Call Number/)
    year = year_raw ? year_raw[1].to_i : 0
    call_number_raw = datakoleksi_raw.match(/Call Number: (SK-\d+)/)
    call_number = call_number_raw ? call_number_raw[1] : "SK-???"
    object = {
      title: title,
      author: author_all,
      link: link,
      year: year,
      call_number: call_number
    }
    puts "Got something by #{author_all}"
    res << object
  end
  res
end

# All constant. Self-explanatory
get_uri = 'http://lontar.cs.ui.ac.id/Lontar/opac/themes/ng/listtipekoleksi.jsp?id=4&start=%d&lokasi=lokal'
entry_per_page = 10
output_csv = 'out.tsv'
output_markdown = 'out.md'
output_json = 'out.json'

result = []

puts "Using #{get_uri} as base uri."

# Start with zero offset, get the number of all collection
offset = 0
current_uri = get_uri % offset
page = Nokogiri::HTML(open(current_uri))
total_document = page.css("table.fullwidth b")[1].text.to_i

puts "Will retrieve #{total_document} documents"

while (offset < total_document)
  puts "Retrieving with offset #{offset}"
  current_uri = get_uri % offset
  current_page_object = parse_lontar(current_uri)
  result = result.concat(current_page_object)
  offset += entry_per_page
end

# Sort the result by year, then by title
result = result.sort do |a,b|
  [b[:year], a[:title]] <=> [a[:year], b[:title]]
end
result = result

# Output the CSV
csv = CSV.generate({ :col_sep => "\t" }) do |csv|
  csv << ['Title', 'Author', 'Year', 'Callnum']
  result.each do |e|
    csv << [e[:title], e[:author], e[:year], e[:call_number]]
  end
end
File.write(output_csv, csv)

# Output the markdown
md = "# lontar.cs.ui.ac.id skripsi / bachelor thesis list"
md += "\n\nGrouped by year. Why i am doing this? Read [README]"
entries_by_year = result.group_by {|e| e[:year]}
entries_by_year.each do |year, entries_in_year|
  year = year == 0 ? "Unknown" : year
  md += "\n\n## #{year}\n\n"
  md += "<table>"
  md += "<thead><th>Author</th><th>Call Number</th><th>Title</th>"
  entries_in_year.each do |entries|
    md += "<tr><td>#{entries[:author]}</td><td>#{entries[:call_number]}</td><td>#{entries[:title]}</td></tr>"
  end
  md += "</tbody></table>"
end
md += "\n\n"
md += "[README]: https://github.com/mufid/lontarcs-parser/blob/master/README.md"
File.write(output_markdown, md)

# Output the JSON

File.write(output_json, JSON.pretty_generate(result))

# -- eof -- don't delete this line.
