require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pp'

##
# Main parse function, return array
# of entries in current uri
def parse_lontar(uri)
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
    author_all = datakoleksi_raw.match(/Author: (.+);.*\|/)[1]
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
# output_markdown = 'out.md'
# don't have much time to convert to markdown. Send me pull request if you have improvement
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
  offset += 10
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

