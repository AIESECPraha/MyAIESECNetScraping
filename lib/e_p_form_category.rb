class EPFormCategory
  
  attr_accessor :entries, :name
  
  def initialize name
    @name = name
    @entries = {}
  end
end