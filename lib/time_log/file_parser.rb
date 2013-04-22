module TimeLog
  class FileParser
    attr_reader :errors

    def initialize(tree)
      @errors = []
      @activity_tree = tree
    end
    
    def set_file(path)
      @path = path
      @line_number = 0
      @prev_mins = nil
      @prev_activities = nil
    end
    
    def process_file(path)
      if File.exist?(path)
        if File.directory?(path)
          process_folder(path)
        else
          set_file(path)
          File.read(path).each_line {|line| parse_line(line) }
          true
        end
      else
        @errors << "File not found: #{path}"
        false
      end
    end
    
    def process_folder(path)
      Dir.new(path).each do |file|
        process_file(File.join(path, file)) unless ['.', '..'].include?(file)
      end
    end
    
    def parse_line(line)
      @line_number += 1
      fields = line.chomp.scan(/^(\d\d\d\d) +([^ ]+) *.* *$/).first

      if fields && fields.size == 2
        if minutes = mins(fields.first)
          unless @prev_mins.nil?
            if minutes > @prev_mins
              process_line(minutes, @prev_activities) unless @prev_activities == '-'
            else
              add_error(line, 'time does not advance')
              return false
            end
          end
           
          @prev_mins = minutes
          @prev_activities = fields.last
          true
        else
          false
        end
      else
        add_error(line, 'line not understood')
        false
      end
    end
    
    def add_error(line, message)
      @errors << "%s:%d: %s - %s" % [File.basename(@path), @line_number, line.chomp, message]
    end
    
    def valid?
      errors.empty?
    end

    private

    def process_line(minutes, activities)
      duration = minutes - @prev_mins
      @activity_tree.load(activities.split('/'), duration)
    end

    def mins(str)
      hours = str[0..1].to_i
      mins  = str[2..3].to_i

      if hours <= 23 && mins <= 59
        (hours * 60) + mins
      else
        add_error(str, 'invalid time')
        false
      end
    end
  end
end