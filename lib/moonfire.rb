# frozen_string_literal: true

require 'moonfire/version'
require 'moonfire/engine'

module Moonfire
  autoload :DeliveryMethod, 'moonfire/delivery_method'
  autoload :ErrorMode, 'moonfire/error_mode'
  autoload :Message, 'moonfire/message'
  autoload :MessageBus, 'moonfire/message_bus'
  autoload :Model, 'moonfire/model'
  autoload :Subscriber, 'moonfire/subscriber'

  # @return [Logger]
  def self.logger
    Engine.config.moonfire.logger ||= Rails.logger || ActiveSupport::Logger.new($stdout)
  end

  # @param logger [Logger]
  # @return [void]
  def self.logger=(logger)
    Engine.config.moonfire.logger = logger
  end

  # @return [Moonfire::MessageBus]
  def self.message_bus
    Engine.config.moonfire.message_bus
  end

  # @param message_bus [Moonfire::MessageBus]
  # @return [void]
  def self.message_bus=(message_bus)
    Engine.config.moonfire.message_bus = message_bus
    install_subscribers_into_message_bus(message_bus)
  end

  # @return [Array<String, Pathname>]
  def self.subscriber_paths
    Engine.config.moonfire.subscriber_paths
  end

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
