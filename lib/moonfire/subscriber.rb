# frozen_string_literal: true

module Moonfire
  class Subscriber
    DEFAULT_SUBSCRIPTION_BLOCK = -> (_) { true }

    # @private
    def self.inherited(subclass)
      super

      # Inherit configuration from the parent subscriber
      subclass.delivery_method = delivery_method
      subscriptions.each do |message_class, condition|
        subclass.subscribes_to(message_class, &condition)
      end
    end

    # @return [#deliver]
    def self.delivery_method
      @delivery_method ||= Moonfire::DeliveryMethod::Inline.new
    end

    # @param delivery_method [Symbol, Class, nil]
    # @return [void]
    def self.delivery_method=(delivery_method)
      locator, options = delivery_method
      @delivery_method = Moonfire::DeliveryMethod.resolve(locator, **(options || {}))
    end

    # @param message [Class<Moonfire::Message>]
    # @yieldparam message [Moonfire::Message]
    # @yieldreturn [Boolean]
    # @return [void]
    def self.subscribes_to(*message_classes, &block)
      message_classes.each do |message_class|
        unless message_class < Moonfire::Message
          raise ArgumentError, 'Message class must be a subclass of Moonfire::Message'
        end

        subscriptions[message_class] = block || DEFAULT_SUBSCRIPTION_BLOCK
      end
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
      delivery_method.deliver(self, message) if accepts?(message)
    end

    # @param message_bus [Moonfire::MessageBus]
    # @return [void]
    def self.install_into_message_bus(message_bus)
      subscriptions.each_key do |message_class|
        message_bus.add_subscriber(message_class, self)
      end
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
