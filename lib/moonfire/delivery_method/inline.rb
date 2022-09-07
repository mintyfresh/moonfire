# frozen_string_literal: true

module Moonfire
  module DeliveryMethod
    class Inline
      # @param subscriber_class [Class<Moonfire::Subscriber>]
      # @param message [Moonfire::Message]
      # @return [void]
      def deliver(subscriber_class, message)
        subscriber_class.new(message).perform
      end
    end
  end
end
