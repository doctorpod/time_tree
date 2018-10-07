module TimeTree
  # Builds the following recursive hash representing a tree of activities:
  #
  # {
  #   'an_activity' => {
  #     minutes: 25,
  #     descriptions: [
  #       'did foo',
  #       'did bar'
  #     ],
  #     children: {} <-- More activities may be nested here
  #   }
  # }
  class ActivityTree
    attr_reader :tree, :output

    def initialize
      @tree = {}
      @output = []
      @max_category_length = 0
    end

    # Loads an activity entry onto the tree.
    # The activity is represented as a array of activity categories, with the
    # most general first, and increasingly specific following.
    #
    # Example:
    #
    # activity_categories: ['home', 'yard_work', 'sweeping']
    # minutes: 25
    # description: 'Swept around the tree'
    #
    def load(activity_categories, minutes, description, level = 0,
             target = @tree)
      activity_categories.unshift 'All' if level.zero?
      category = activity_categories.shift
      populate_category(target, category, description, minutes,
                        activity_categories.empty?)
      update_max_category_length(category, level)

      # rubocop:disable Style/GuardClause
      if activity_categories.any?
        load(activity_categories, minutes, description, level + 1,
             target[category][:children])
      end
      # rubocop:enable Style/GuardClause
    end

    def print
      puts output.join("\n")
    end

    def process(level = 0, target = tree)
      target.sort.each do |activity_category, values|
        output << format_line(level, activity_category, values)
        process(level + 1, values[:children]) if values[:children].any?
      end
    end

    private

    INDENT = 2

    def format_line(level, activity_category, values)
      format(
        format_string,
        indent_activity_category(level, activity_category),
        values[:minutes],
        to_hrs_mins(values[:minutes]),
        values[:descriptions].uniq.join(' - ')
      ).rstrip
    end

    def format_string
      "%-#{@max_category_length + 1}s %4d min (%s)  %s"
    end

    def indent_activity_category(level, activity_category)
      "#{(1..level * INDENT).to_a.map { ' ' }.join}#{activity_category}"
    end

    def populate_category(target, category, description, minutes, is_leaf)
      target[category] ||= { minutes: 0, children: {}, descriptions: [] }
      target[category][:descriptions] << description if is_leaf && description
      target[category][:minutes] += minutes
    end

    def to_hrs_mins(mins)
      hours = (mins / 60.0).floor
      format('%d:%02d', hours, mins - (hours * 60))
    end

    def update_max_category_length(activity, level)
      @max_category_length = [
        @max_category_length,
        (level * INDENT) + activity.length
      ].sort.last
    end
  end
end
