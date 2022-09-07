# frozen_string_literal: true

module Moonfire
  class Subscriber
    DEFAULT_SUBSCRIPTION_BLOCK = -> (_) { true }

    # @param message [Class<Moonfire::Message>]
    # @yieldparam message [Moonfire::Message]
    # @yieldreturn [Boolean]
    # @return [void]
    def self.subscribes_to(message_class, &block)
      subscriptions[message_class] = block || DEFAULT_SUBSCRIPTION_BLOCK
    end

    # @return [Hash{Class<Moonfire::Message> => Proc}]
    def self.subscriptions
      @subscriptions ||= {}
    end

    # @param message [Moonfire::Message]
    # @return [Boolean]
    def self.accepts?(message)
      message_class = message.class

      while message_class < Moonfire::Message
        condition = subscriptions[message_class]
        return condition.call(message) if condition

        # Check for subscriptions to the parent class
        message_class = message_class.superclass
      end

      false
    end

    # @param message [Moonfire::Message]
    # @return [void]
    def self.deliver(message)
      new(message).perform if accepts?(message)
    end

    # @return [Moonfire::Message]
    attr_reader :message

    # @param message [Moonfire::Message]
    def initialize(message)
      @message = message
    end

    # @abstract
    def perform
      raise NotImplementedError, "#{self.class}#perform is not implemented"
    end
  end
end
