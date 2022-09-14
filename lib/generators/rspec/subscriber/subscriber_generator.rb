# frozen_string_literal: true

module Rspec
  class SubscriberGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def create_subscriber
      template 'subscriber_spec.rb.erb', "spec/subscribers/#{file_name}_spec.rb"
    end

  private

    def class_name
      file_name.classify
    end

    def file_name
      "#{super.chomp('_subscriber')}_subscriber"
    end
  end
end
