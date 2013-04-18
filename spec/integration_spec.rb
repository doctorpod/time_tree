require 'time_log/activity_tree'
require 'time_log/file_parser'
require 'helper'

module TimeLog
  describe 'Integration' do
    it "works!" do
      puts
      tree = ActivityTree.new
      parser = FileParser.new(tree)
      parser.process_file(fixtures('real.txt'))
      
      if parser.valid?
        tree.print
      else
        STDERR.puts "ERRORS:"
        STDERR.puts parser.errors.join("\n")
      end
    end
  end
end