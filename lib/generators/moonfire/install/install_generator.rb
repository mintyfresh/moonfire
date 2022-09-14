# frozen_string_literal: true

module Moonfire
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_application_subscriber
      copy_file 'application_subscriber.rb', 'app/subscribers/application_subscriber.rb'
    end

    def install_test_message_bus
      inject_into_file 'config/environments/test.rb', before: "\nend\n" do
        <<~RUBY.indent(2)
          \n\n# Use a mock message bus in during testing
          require 'moonfire/rspec'
          config.moonfire.message_bus = Moonfire::RSpec::TestMessageBus.new
        RUBY
      end
    end
  end
end
