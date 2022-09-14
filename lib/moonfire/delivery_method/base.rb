# frozen_string_literal: true

module Moonfire
  module DeliveryMethod
    class Base
      # @abstract
      # @param subscriber_class [Class<Moonfire::Subscriber>]
      # @param message [Moonfire::Message]
      # @return [void]
      def deliver(subscriber_class, message)
        raise NotImplementedError, "#{self.class}#deliver is not implemented"
      end
    end
  end
end
