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

    initializer 'moonfire.subscriber_paths' do |app|
      Moonfire.subscriber_paths << app.root.join('app/subscribers')
    end

    config.to_prepare do
      Moonfire.install_subscribers_into_message_bus(Moonfire.default_message_bus)
    end
  end
end
