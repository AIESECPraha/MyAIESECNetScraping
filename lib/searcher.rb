require 'rubygems'
require 'active_record'

puts "Connecting to database..."

ActiveRecord::Base.establish_connection ({
  :adapter => "mysql",
  :host => "localhost",
  :username => "root",
  :password => "",
  :database => "myaiesecnetscraping"})

connection = ActiveRecord::Base.connection

connection.execute("SELECT id, country FROM ep_forms WHERE ep_forms.german>3 AND maximum_duration>23").each do |row|
  #puts "<a href=\"http://myaiesec.net/exchange/viewep.do?operation=executeAction&epId=#{row[0].to_s}\">#{row[1].to_s}</a>"
  puts "#{row[1].to_s}:\t\thttp://myaiesec.net/exchange/viewep.do?operation=executeAction&epId=#{row[0].to_s}"
end