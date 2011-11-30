require 'rubygems'
require 'active_record'
require_relative 'all_ep_forms'
require_relative 'e_p_form'
require_relative 'time_investigator'

puts "Connecting to database..."

ActiveRecord::Base.establish_connection ({
  :adapter => "mysql",
  :host => "localhost",
  :username => "root",
  :password => "",
  :database => "myaiesecnetscraping"})

connection = ActiveRecord::Base.connection

puts "Connection established."

skills_in_table = []
connection.execute("select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ep_forms'").each {|row| skills_in_table << row[0] }

puts "Logging in..."

agent = Mechanize.new
login! agent, 'thomas.jandecka@aiesec.cz', 'C7A5Z1'

puts "Logged in."

ti = TimeInvestigator.new
all_ep_forms(agent, "29.10.2011", "03.05.2012", ti) do |id, page|
  form = EPForm.new(id, page)
  ti.leap 'parsing'
  skills_in_table = form.serialize(skills_in_table, connection)
  puts "EP form extracted (#{ti.stop('db')})"
end