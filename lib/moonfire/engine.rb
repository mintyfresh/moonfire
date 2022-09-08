# frozen_string_literal: true

begin
  require 'factory_bot_rails'
  require 'faker'
rescue LoadError
  # Optional dependencies
end

module Moonfire
  class Engine < ::Rails::Engine
    isolate_namespace Moonfire

    config.moonfire = ActiveSupport::OrderedOptions.new
    config.moonfire.subscriber_paths = []

    initializer 'moonfire.message_bus' do
      config.moonfire.message_bus ||= Moonfire::MessageBus.new
    end

    initializer 'moonfire.subscriber_paths' do |app|
      config.moonfire.subscriber_paths << app.root.join('app/subscribers')
    end

    config.to_prepare do
      Moonfire.install_subscribers_into_message_bus(Moonfire.message_bus)
    end
  end
end
