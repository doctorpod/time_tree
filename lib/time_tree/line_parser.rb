module TimeTree
  # Sequentially processes a line. Maintains state between calls.
  class LineParser
    attr_reader :errors

    def initialize(tree, options)
      @activity_tree = tree
      @options = options
      @line_number = 0
      @errors = []
    end

    # rubocop:disable Metric/MethodLength
    def parse(path, line)
      @line_number += 1

      case line.chomp.sub(/#.*/, '').strip
      when '' then true # ignore blank lines and comments

      # Date line
      when %r{^(\d\d\d\d\/\d\d\/\d\d)\s*[\w\s]*\s*(\| (.*))?$}
        # 1: date, 2: tags with leading pipe (not used), 3: tags (not used yet)
        save_date(Regexp.last_match(1))

      # Context tags - Not used yet
      when /^\|(.+)$/ then true

      # Event line
      when %r{^(\d\d\d\d)\s+([-\w\/&]+)\s*([\w\s]+)*(\|\s*(.*))?$}
        # 1: time, 2: activity, 3: description, 5: tags (not used yet)
        process_line(Regexp.last_match(1), Regexp.last_match(2),
                     Regexp.last_match(3), path, line)

      else add_error(path, line, 'line not understood')
      end
    end
    # rubocop:enable Metric/MethodLength

    def valid?
      errors.empty?
    end

    private

    def add_error(path, line, message)
      @errors << format(
        '%s:%d: %s - %s',
        File.basename(path), @line_number, line.chomp, message
      )
      false
    end

    def load_tree(minutes, activities, comment)
      duration = minutes - @prev_mins
      @activity_tree.load(activities.split('/'), duration, comment)
    end

    def parse_mins(str, path)
      return 1440 if str == '0000' && @prev_mins
      hours = str[0..1].to_i
      mins  = str[2..3].to_i

      if hours <= 23 && mins <= 59
        (hours * 60) + mins
      else
        add_error(path, str, 'invalid time')
      end
    end

    def process_line(time, activity, comment, path, line)
      return false unless (minutes = parse_mins(time, path))
      return false unless time_advances?(minutes, path, line)
      process_verified_line(minutes) unless @prev_mins.nil?
      save_previous(minutes, activity, comment)
      true
    end

    def process_verified_line(minutes)
      if @prev_activity != '-' &&
         SelectionDeterminer.selected?(@date, @prev_context, @options)
        load_tree(minutes, @prev_context, @prev_comment)
      end
    end

    def save_date(date)
      @date = date
      save_previous(nil, nil, [])
      true
    end

    def save_previous(mins, activity, comment)
      @prev_mins = mins
      @prev_activity = activity
      @prev_context = activity unless %w[- &].include?(activity)
      @prev_comment = comment.nil? || comment.empty? ? nil : comment
    end

    def time_advances?(minutes, path, line)
      return true if @prev_mins.nil?
      minutes > @prev_mins || add_error(path, line, 'time does not advance')
    end
  end
end
