require 'rubygems'
require 'mechanize'
require_relative 'all_ep_forms'

def get_hash_list page
  puts page.search("div[@class='left-content box']/table/tbody/tr/td[not(@class)]")
end

############### DEBUG ####################
agent = Mechanize.new
login! agent, 'thomas.jandecka@aiesec.cz', 'C7A5Z1'

all_ep_forms(agent, "28.05.2011", "28.05.2012") do |id,page|
  get_hash_list page
  break
end