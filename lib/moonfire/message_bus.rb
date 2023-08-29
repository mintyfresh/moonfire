# frozen_string_literal: true

module Moonfire
  class MessageBus
    def initialize
      @error_interceptors = []
      @subscriptions = {}
    end

    # @param block [Proc]
    # @yieldparam subscriber [Class<Moonfire::Subscriber>]
    # @yieldparam message [Moonfire::Message]
    # @yieldparam error [StandardError]
    # @return [void]
    def add_error_interceptor(&block)
      @error_interceptors << block
    end

    # @param message_class [Class<Moonfire::Message>]
    # @param subscriber_class [Class<Moonfire::Subscriber>]
    # @return [void]
    def add_subscriber(message_class, subscriber_class)
      (@subscriptions[message_class] ||= Set.new) << subscriber_class
    end

    # @param message_class [Class<Moonfire::Message>]
    # @param subscriber_class [Class<Moonfire::Subscriber>]
    # @return [void]
    def remove_subscriber(message_class, subscriber_class)
      @subscriptions[message_class]&.delete(subscriber_class)
    end

    # @return [void]
    def clear_subscribers
      @subscriptions.clear
    end

    # @param message_class [Class<Moonfire::Message>]
    # @return [Set<Class<Moonfire::Subscriber>>]
    def subscribers_for(message_class)
      @subscriptions[message_class] || []
    end

    # @param message [Moonfire::Message]
    # @yieldparam subscriber [Class<Moonfire::Subscriber>]
    # @yieldparam message [Moonfire::Message]
    # @yieldparam error [StandardError]
    # @return [void]
    def deliver(message)
      message_class = message.class

      while message_class < Moonfire::Message
        subscribers_for(message_class).each do |subscriber_class|
          deliver_message_to_subscriber(subscriber_class, message)
        rescue StandardError => error
          # Defer any error handling to the message publisher
          yield(subscriber_class, message, error) if block_given?

          # Pass the error to any error interceptors
          notify_error_interceptors(subscriber_class, message, error)
        end

        # Check for subscriptions to the parent class
        message_class = message_class.superclass
      end
    end

    # @param subscriber_class [Class<Moonfire::Subscriber>]
    # @param message [Moonfire::Message]
    # @param error [StandardError]
    # @return [void]
    def notify_error_interceptors(subscriber_class, message, error)
      @error_interceptors.each do |interceptor|
        interceptor.call(subscriber_class, message, error)
      end
    end

  private

    # @param subscriber_class [Class<Moonfire::Subscriber>]
    # @param message [Moonfire::Message]
    # @return [void]
    def deliver_message_to_subscriber(subscriber_class, message)
      subscriber_class.deliver(message)
    end
  end
end
