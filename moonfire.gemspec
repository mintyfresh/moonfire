# frozen_string_literal: true

require_relative 'lib/moonfire/version'

Gem::Specification.new do |spec|
  spec.name        = 'moonfire'
  spec.version     = Moonfire::VERSION
  spec.authors     = ['Minty Fresh']
  spec.email       = ['7896757+mintyfresh@users.noreply.github.com']
  spec.homepage    = 'https://github.com/mintyfresh/moonfire'
  spec.summary     = 'Lightweight pub/sub for Ruby on Rails'
  spec.description = 'Publish and subscribe to events in your Rails application'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '>= 7'

  spec.add_development_dependency 'annotate'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'sqlite3'
end
