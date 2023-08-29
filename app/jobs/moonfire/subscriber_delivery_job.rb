# frozen_string_literal: true

module Moonfire
  class SubscriberDeliveryJob < ApplicationJob
    queue_as :subscribers

    rescue_from StandardError do |error|
      subscriber_class, message_class, message_attributes = arguments
      message = message_class.new(message_attributes)

      # Pass the error to any error interceptors
      Moonfire.message_bus.notify_error_interceptors(subscriber_class, message, error)

      # Bubble the error to job runner
      raise error
    end

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
