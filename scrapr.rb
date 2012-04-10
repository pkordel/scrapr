require 'mechanize'

agent = Mechanize.new
base_url = 'http://skoleverkstedet.deichman.no/'

page  = agent.get(base_url + 'tema.htm')

links = []
links << page.search('//ul/li/a')
links << page.search('//ul/li/strong/a')
links = links.flatten.sort

pages = []
links.each { |l| pages << [l.text.gsub(/\r\n\s+/, ''), l[:href]] }

page = agent.get(base_url + pages.first.last)
#links = page.search("//a[starts-with(@href, 'http://www.deich.folkebibl.no/cgi-bin/')]")
links = page.search("//td/a[descendant::img]")

puts links.size
