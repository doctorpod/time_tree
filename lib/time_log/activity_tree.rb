module TimeLog
  class ActivityTree
    attr_reader :activities
    
    def initialize
      @activities = {}
    end
    
    def load(activities, minutes, level = 0, target = @activities)
      activities.unshift 'All' if level == 0
      activity = activities.shift
      target[activity] = {:minutes => 0, :children => {}} unless target[activity]
      target[activity][:minutes] += minutes
      load(activities, minutes, level+1, target[activity][:children]) if activities.any?
    end
    
    def print(level = 0, target = activities)
      target.each do |activity, values|
        puts "%-25s %4d min (%.2f hrs)" % ["#{(1..level*2).to_a.map{' '}.join}#{activity}", values[:minutes],
                                             values[:minutes]/60.0]
        print(level+1, values[:children]) if values[:children].any?
      end
    end
  end
end