require 'rubygems'

class TimeInvestigator
  def initialize
    @actions = {}
    @time = Time.now
  end
  def reset
    @time = Time.now
  end
  def leap label
    @actions[label] = (Time.now - @time) * 1000.0
    @time = Time.now
  end
  def stop label
    leap label
    res = ''
    @actions.each { |lbl,time| res += lbl + ': ' + time.to_i.to_s + "ms;\t" }
    return res
  end
end
