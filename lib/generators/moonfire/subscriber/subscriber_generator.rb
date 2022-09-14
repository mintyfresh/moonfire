# frozen_string_literal: true

module Moonfire
  class SubscriberGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def create_subscriber
      template 'subscriber.rb.erb', "app/subscribers/#{file_name}.rb"
    end

    hook_for :test_framework

  private

    def class_name
      file_name.classify
    end

    def parent_class_name
      defined?(ApplicationSubscriber) ? 'ApplicationSubscriber' : 'Moonfire::Subscriber'
    end

    def file_name
      "#{super.chomp('_subscriber')}_subscriber"
    end
  end
end
