
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'time_tree/version'

Gem::Specification.new do |gem|
  gem.name          = 'time_tree'
  gem.version       = TimeTree::VERSION
  gem.authors       = ['Andy White']
  gem.email         = ['andy@wireworldmedia.co.uk']
  gem.description   = 'Summarises a time file'
  gem.summary       = 'Summarises a time file'
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'byebug'
end
