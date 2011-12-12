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
login! agent, 'your_login', 'your_password'

puts "Logged in."

ti = TimeInvestigator.new
all_ep_forms(agent, "29.10.2011", "03.05.2012", ti) do |id, page|
  form = EPForm.new(id, page)
  ti.leap 'parsing'
  skills_in_table = form.serialize(skills_in_table, connection)
  puts "EP form extracted (#{ti.stop('db')})"
end


=begin
Varianta pre zápis celej databázy to txt
my_file = File.new("db.txt","w")
all_ep_forms(agent, "5.12.2007", "30.09.2012", ti) do |id, page|
preskoc=false
a=id.to_s
page.parser.xpath(('/html/body/form/table/tr/td/table/tr/td/div/div/table/tr/td')).each do |node|
    if ((node['class']!="td-grayclass-leftalign" and not((node.text).to_s.include? "Status") and not((node.text).to_s.include? "Exchange Type")  ) or (node.text).to_s.include? "Native" or (node.text).to_s.include? "Excellent" or (node.text).to_s.include? "Good" or (node.text).to_s.include? "Basic")
        then
        if (((node.text).to_s.delete "\t\r\n").include? "ProfessionalInformation" or ((node.text).to_s.delete "\t\r\n").include? "AIESECInformation") then  preskoc=true end
        if (((node.text).to_s.delete "\t\r\n").include? "PersonalPreferences" or ((node.text).to_s.delete "\t\r\n").include? "Backgrounds") then preskoc=false end
        if (node['colspan']!="2" and preskoc==false)
        then
        a+=';'+(((node.text).to_s).delete "\t\r\n")
        end
        end
end
my_file.puts a
  
  puts "EP form extracted (#{ti.stop('db')})"
end
=end
