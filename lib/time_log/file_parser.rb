require 'date'
require 'time_log/date_calculator'

module TimeLog
  class FileParser
    include DateCalculator 
    attr_reader :errors

    def initialize(tree, options)
      @errors = []
      @activity_tree = tree
      @options = options
    end
    
    def set_file(path)
      @path = path
      @line_number = 0
    end
    
    def set_date(date)
      @date = date
      @prev_mins = nil
      @prev_activities = nil
    end
    
    def process_file(path)
      if File.exist?(path)
        if File.directory?(path)
          process_folder(path)
        else
          set_file(path)
puts 'reading '+path
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
        process_file(File.join(path, file)) unless file =~ /^\./
      end
    end
    
    def parse_line(line)
      @line_number += 1
      
      case line.chomp.sub(/#.*/, '').strip
      when ''
        # ignore blank lines and comments
        true

      when /^(\d\d\d\d\/\d\d\/\d\d) *.*$/
puts 'its a date '+$1
        set_date($1)
        true

      when /^(\d\d\d\d) +([^ ]+) *.*$/
puts 'its a time '+$1+':'+$2
        if minutes = mins($1)
          unless @prev_mins.nil?
            if minutes > @prev_mins
puts 'mins have advanced'
              if @prev_activities != '-' && selected?(@date, @prev_activities)
puts 'proc line'
                process_line(minutes, @prev_activities) 
              end
            else
              add_error(line, 'time does not advance')
              return false
            end
          end
           
          @prev_mins = minutes
          @prev_activities = $2
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
    
    def selected?(date = @date, activities = '', options = @options)
      date_options = [:today, :yesterday, :week, :month, :date, :range]
      parsed_date = Date.parse(date)
      
      (
        options.detect { |key, val| date_options.include?(key) }.nil? ||
          options[:today] && parsed_date == Date.today ||
          options[:yesterday] && parsed_date == Date.today-1 ||
          options[:week] && in_prev_week?(parsed_date, options[:week]) ||
          options[:month] && in_prev_month?(parsed_date, options[:month]) ||
          options[:date] && parsed_date == Date.parse(options[:date]) ||
          options[:range] && parsed_date >= Date.parse(options[:range].split(':').first) &&
                             parsed_date <= Date.parse(options[:range].split(':').last)
      ) && 
      (
        options[:filter] && options[:filter].detect { |f| activities =~ Regexp.new(f) } ||
          options[:filter].nil?
      )
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