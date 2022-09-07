# frozen_string_literal: true

require 'moonfire/version'
require 'moonfire/engine'

module Moonfire
  autoload :DeliveryMethod, 'moonfire/delivery_method'
  autoload :Message, 'moonfire/message'
  autoload :MessageBus, 'moonfire/message_bus'
  autoload :Model, 'moonfire/model'
  autoload :Publisher, 'moonfire/publisher'
  autoload :Subscriber, 'moonfire/subscriber'

  mattr_accessor :default_message_bus, default: MessageBus.new
  mattr_accessor :subscriber_paths, default: []

  # Loads all subscribers from the configured subscriber paths and installs them
  # into the given message bus.
  #
  # @param message_bus [Moonfire::MessageBus]
  # @return [void]
  def self.install_subscribers_into_message_bus(message_bus)
    subscriber_paths.each do |path|
      subscribers = Dir["#{path}/**/*_subscriber.rb"].flat_map do |file|
        name = file.sub(path.to_s, '').chomp('.rb')
        name = name[1..] if name.starts_with?('/')

        name.classify.constantize
      end

      subscribers.each do |subscriber|
        subscriber.install_into_message_bus(message_bus) if subscriber < Subscriber
      end
    end
  end
end
