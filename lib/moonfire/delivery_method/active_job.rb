# frozen_string_literal: true

module Moonfire
  module DeliveryMethod
    class ActiveJob < Base
      # @param job_options [Hash]
      def initialize(**job_options)
        super()
        @job_options = job_options
      end

      # @param subscriber_class [Class<Moonfire::Subscriber>]
      # @param message [Moonfire::Message]
      # @return [void]
      def deliver(subscriber_class, message)
        Moonfire::SubscriberDeliveryJob
          .set(**@job_options)
          .perform_later(subscriber_class, message.class, message.attributes)
      end
    end
  end
end
