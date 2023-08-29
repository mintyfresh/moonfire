# frozen_string_literal: true

module Moonfire
  class Message
    include ActiveModel::Model
    include ActiveModel::Attributes

    # @param message_bus [Moonfire::MessageBus]
    # @return [void]
    def self.publish(message_bus: Moonfire.message_bus, **, &)
      message_bus.deliver(new(**), &)
    end
  end
end
