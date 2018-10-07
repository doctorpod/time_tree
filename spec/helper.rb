require 'byebug'
require 'time_tree'

def fixtures(path = '')
  File.expand_path(File.join('..', '..', 'fixtures', path), __FILE__)
end
