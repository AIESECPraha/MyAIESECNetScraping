require 'rubygems'
require 'active_record'


ActiveRecord::Base.establish_connection(
  :adapter => 'mysql2',
  :database => 'myaiesecnetscraping',
  :username => 'root',
  :password => '',
  :host => 'localhost',
  :port => 3306
)

rows = {
  '456789' => ['one', 'two', 'three'],
  '457312' => ['two', 'three', 'five'],
  '496587' => ['one', 'two', 'six'],
  '123457' => ['twenty one', 'three'],
}
sql = ActiveRecord::Base.connection();
skills_in_table = []
sql.execute("select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ep_forms'").each {|row| skills_in_table << row[0] }

rows.each do |id, skills|
  missing_skills = skills-skills_in_table
  missing_skills.each do |skill|
    sql.execute("ALTER TABLE `ep_forms` ADD COLUMN `#{skill}` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `id`;")
  end
  colums_sql_string = "`id`"
  skills.each {|skill| colums_sql_string += ", `#{skill}`" }
  data_sql_string = id
  skills.each {|skill| data_sql_string += ", 1" }
  sql.execute("INSERT INTO `ep_forms` (#{colums_sql_string}) VALUES (#{data_sql_string});")
  skills_in_table += missing_skills
  puts missing_skills.inspect
end


