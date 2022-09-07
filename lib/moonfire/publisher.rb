# frozen_string_literal: true

module Moonfire
  module Publisher
    # @param message [Moonfire::Message]
    # @param validate [Boolean]
    # @yieldparam subscriber [Class<Moonfire::Subscriber>]
    # @yieldparam message [Moonfire::Message]
    # @yieldparam error [StandardError]
    # @return [void]
    def publish(message, validate: true, &block)
      message.validate! if validate

      message_bus.deliver(message, &block)
    end

  protected

    # @return [Moonfire::MessageBus]
    def message_bus
      Moonfire.default_message_bus
    end
  end
end
