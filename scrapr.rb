#encoding: utf-8
require 'mechanize'
require 'csv'

agent = Mechanize.new
base_url = 'http://skoleverkstedet.deichman.no/'

CSV_FILE_PATH = File.join(File.dirname(__FILE__), "output.csv")


page  = agent.get(base_url + 'tema.htm')

links = page.search("//ul/li/a | //ul/li/strong/a")

pages = []
links.each { |l| pages << [l.text.gsub(/\r\n\s+/, ''), l[:href]] }

expr1 = "//td/a[starts-with(@href, 'http://www.deich.folkebibl.no/') and not(descendant::img)]/.."
expr2 = "//td/strong/a[starts-with(@href, 'http://www.deich.folkebibl.no/') and not(descendant::img)]/.."
rows = []
rows << %w[Tema Lenk Tittel Text]
pages.each do |p|
  url = base_url + p.last
  page = nil
  begin
    page  = agent.get(url)
  rescue => e
    next
  end
  if page
    links = page.search("#{expr1}|#{expr2}")
    row = []
    links.each do |l|
      row = [p.first]
      link  = ""
      title = ""
      text  = []
      l.children.each do |c|
        if c.name == 'a'
          link  = c[:href]
          title = c.text.gsub(/\s+/, ' ').strip
        end
        if c.name == 'text' || c.name == 'p'
          t = c.text.gsub(/\r\n\s+/, '').strip
          text << t unless t == ""
        end
      end
      row << link << title << text.compact.join(' ')
      rows << row
    end
  end
end

CSV.open(CSV_FILE_PATH, 'wb') do |csv|
  csv << rows.shift
  rows.each { |r| csv << r }
end
