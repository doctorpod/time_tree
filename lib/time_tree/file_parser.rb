require 'date'
require 'time_tree/date_calculator'

module TimeTree
  class FileParser
    include DateCalculator 
    attr_reader :errors

    def initialize(tree, options)
      @errors = []
      @activity_tree = tree
      @options = options
    end
    
    def find_path(paths)
      paths.each do |path|
        return path if File.exist?(path)
      end
      
      @errors << "File not found in: #{paths.join(', ')}"
      false
    end
    
    def set_file(path)
      @path = path
      @line_number = 0
    end
    
    def set_date(date)
      @date = date
      @prev_mins = nil
      @prev_activities = nil
      @prev_comment = nil
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
        set_date($1)
        true

      when /^(\d\d\d\d) +([-\w\/]+) *(.*)$/
        if minutes = mins($1)
          unless @prev_mins.nil?
            if minutes > @prev_mins
              if @prev_activities != '-' && selected?(@date, @prev_activities)
                process_line(minutes, @prev_activities, @prev_comment) 
              end
            else
              add_error(line, 'time does not advance')
              return false
            end
          end
           
          @prev_mins = minutes
          @prev_activities = $2.strip
          @prev_comment = $3.size > 0 ? $3 : nil
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
          options[:all] ||
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

    def process_line(minutes, activities, comment)
      duration = minutes - @prev_mins
      @activity_tree.load(activities.split('/'), duration, comment)
    end

    def mins(str)
      return 1440 if str == '0000' && @prev_mins
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