module TimeTree
  class ActivityTree
    attr_reader :activities, :output
    
    def initialize
      @activities = {}
      @output = []
    end
    
    def load(activities, minutes, description, level = 0, target = @activities)
      activities.unshift 'All' if level == 0
      activity = activities.shift
      target[activity] = {:minutes => 0, :children => {}, :descriptions => []} unless target[activity]
      target[activity][:minutes] += minutes
      target[activity][:descriptions] << description if activities.size == 0 && description
      load(activities, minutes, description, level+1, target[activity][:children]) if activities.any?
    end
    
    def process(level = 0, target = activities)
      target.sort.each do |activity, values|
        output << "%-25s %4d min (%s)  %s" % ["#{(1..level*2).to_a.map{' '}.join}#{activity}",
                                                values[:minutes],
                                                to_hrs_mins(values[:minutes]),
                                                values[:descriptions].uniq.join(' - ')]
        process(level+1, values[:children]) if values[:children].any?
      end
    end

    def to_hrs_mins(mins)
      hours = (mins/60.0).floor
      "%d:%02d" % [hours, mins - (hours*60)]
    end
    
    def print
      puts output.join("\n")
    end
  end
end
