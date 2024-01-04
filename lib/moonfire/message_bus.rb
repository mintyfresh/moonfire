# frozen_string_literal: true

module Moonfire
  class MessageBus
    # @return [Symbol]
    attr_reader :error_mode

    def initialize
      @error_mode         = Engine.config.moonfire.error_mode || ErrorMode::LOG
      @error_interceptors = []
      @subscriptions      = {}
    end

    # @param value [Symbol]
    # @return [void]
    def error_mode=(value)
      unless ErrorMode.all.include?(value)
        raise ArgumentError, "invalid error mode: #{value.inspect} (expected one of #{ErrorMode.all.inspect})"
      end

      @error_mode = value
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
    def deliver(message, &block) # rubocop:disable Naming/BlockForwarding
      last_error = nil
      message_class = message.class

      while message_class < Moonfire::Message
        subscribers_for(message_class).each do |subscriber_class|
          last_error = deliver_message_to_subscriber(subscriber_class, message, &block) # rubocop:disable Naming/BlockForwarding
        end

        # Check for subscriptions to the parent class
        message_class = message_class.superclass
      end

      # Raise the last error if configured to do so
      raise last_error if last_error && error_mode == ErrorMode::RAISE_LAST
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
    # @yieldparam subscriber [Class<Moonfire::Subscriber>]
    # @yieldparam message [Moonfire::Message]
    # @yieldparam error [StandardError]
    # @return [void]
    def deliver_message_to_subscriber(subscriber_class, message)
      subscriber_class.deliver(message)
    rescue StandardError => error
      # Defer any error handling to the message publisher
      yield(subscriber_class, message, error) if block_given?

      # Pass the error to any error interceptors
      notify_error_interceptors(subscriber_class, message, error)

      # Take an action based on the configured error mode
      case error_mode
      when ErrorMode::LOG         then log_error_and_backtrace(error)
      when ErrorMode::RAISE_FIRST then raise error
      when ErrorMode::RAISE_LAST  then error # return the error, defer raising until the end
      end
    end

    # @param error [StandardError]
    # @return [void]
    def log_error_and_backtrace(error)
      Moonfire.logger.error { "Moonfire::MessageBus: #{error.class}: #{error.message}" }
      Moonfire.logger.debug { error.backtrace.join("\n") }
    end
  end
end
