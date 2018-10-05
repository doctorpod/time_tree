module TimeTree
  class ActivityTree
    attr_reader :activities, :output

    def initialize
      @activities = {}
      @output = []
      @max_activity_length = 0
    end

    def load(activities, minutes, description, level = 0, target = @activities)
      activities.unshift 'All' if level == 0
      activity = activities.shift
      target[activity] = {:minutes => 0, :children => {}, :descriptions => []} unless target[activity]
      target[activity][:minutes] += minutes
      target[activity][:descriptions] << description if activities.size == 0 && description
      @max_activity_length = [@max_activity_length, (level*INDENT)+activity.length].sort.last
      load(activities, minutes, description, level+1, target[activity][:children]) if activities.any?
    end

    def process(level = 0, target = activities)
      format_string = "%-#{@max_activity_length+1}s %4d min (%s)  %s"

      target.sort.each do |activity, values|
        output << (format_string % ["#{(1..level*INDENT).to_a.map{' '}.join}#{activity}",
          values[:minutes],
          to_hrs_mins(values[:minutes]),
          values[:descriptions].uniq.join(' - ')]).rstrip

        process(level+1, values[:children]) if values[:children].any?
      end
    end

    def print
      puts output.join("\n")
    end

    private

    INDENT = 2

    def to_hrs_mins(mins)
      hours = (mins/60.0).floor
      "%d:%02d" % [hours, mins - (hours*60)]
    end
  end
end
