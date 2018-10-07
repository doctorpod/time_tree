require 'time_tree/line_parser'

module TimeTree
  # Find all files under folder and submit for processing
  class FileFinder
    attr_reader :errors

    def add_error(message)
      @errors << message
      false
    end

    def initialize(tree, options, line_parser = nil)
      @errors = []
      @line_parser = line_parser || LineParser.new(tree, options)
    end

    def find_path(paths)
      paths.each do |path|
        return path if File.exist?(path)
      end

      @errors << "File not found in: #{paths.join(', ')}"
      false
    end

    def process_file(path)
      if File.exist?(path)
        if File.directory?(path)
          process_folder(path)
        else
          File.read(path).each_line { |line| @line_parser.parse(path, line) }
          true
        end
      else
        add_error("File not found: #{path}")
      end
    end

    def process_folder(path)
      Dir.new(path).each do |file|
        process_file(File.join(path, file)) unless file =~ /^\./
      end
    end

    def valid?
      errors.empty?
    end
  end
end
