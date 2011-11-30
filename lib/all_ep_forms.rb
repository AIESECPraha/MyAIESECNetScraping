require 'rubygems'
require 'mechanize'

def login! agent, user, pw
  page = agent.get 'http://myaiesec.net/'
  login_form = page.form 'loginForm'
  login_form.userName = user
  login_form.password = pw
  agent.submit(login_form)
end

def all_ep_forms agent, date_from, date_to, ti
  counter = 1
  page = agent.current_page
  until page.search("[@color='green']").to_s.include? "No Records Available."
    puts "Loading new index page..."
    page = agent.post 'http://www.myaiesec.net/exchange/browsestudent.do?operation=BrowseStudentSearchResult&page=' + counter.to_s,
        {
          'date_from' => date_from.to_s,
          'date_to' => date_to.to_s,
          'searchbrowsesn' => 'Search',
          'duration_from' => '6',
          'duration_to' => '78',
          'status' => '-1',
          'browsetype' => 'ep',
          'buttontype' => '',
          'countrycode' => '',
          'questiontext' => '',
          'sncode' => '',
          'statusid' => '',
          'page' => '1'
        },
        {
          'Cookie' => agent.cookies.first.to_s
        }
    page.search("font[@class='linkclass']").xpath("@onclick").children.each do |node|
      ep_id = node.to_s.split("'")[1]
      agent.transact do |transAgent|
        transAgent.get("http://www.myaiesec.net/exchange/viewep.do",
          {
            'operation' => 'executeAction',
            'epId' => ep_id
          },
          nil,
          {
            'Cookie' => agent.cookies.first.to_s
          }) {|getPage| ti.leap "site loading"; yield ep_id, getPage }
      end
    end
    counter += 1
  end  
end


############### DEBUG ####################
#agent = Mechanize.new
#login! agent, 'thomas.jandecka@aiesec.cz', 'C7A5Z1'
#
#all_ep_forms(agent, "28.05.2011", "28.05.2012") do |id,page|
#  puts page.search("[@class='page-mainHeader-class']").text
#  break
#end