# frozen_string_literal: true

module Moonfire
  class SubscriberDeliveryJob < ApplicationJob
    queue_as :subscribers

    # @param subscriber_class [Class<Moonfire::Subscriber>]
    # @param message_class [Class<Moonfire::Message>]
    # @param message_attributes [Hash]
    # @return [void]
    def perform(subscriber_class, message_class, message_attributes)
      message = message_class.new(message_attributes)

      subscriber_class.new(message).perform
    end
  end
end
