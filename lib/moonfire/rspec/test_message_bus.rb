# frozen_string_literal: true

module Moonfire
  module RSpec
    class TestMessageBus < Moonfire::MessageBus
      # @return [Hash{Class<Moonfire::Subscriber> => Array<Moonfire::Message>}]
      attr_reader :deliveries
      # @return [Array<Moonfire::Message>]
      attr_reader :messages

      def initialize
        super
        @deliveries ||= {}
        @messages ||= []
      end

      # @param message [Moonfire::Message]
      # @return [void]
      def deliver(message)
        @messages << message
        super
      end

    protected

      # @param subscriber_class [Class<Moonfire::Subscriber>]
      # @param message [Moonfire::Message]
      # @return [void]
      def deliver_message_to_subscriber(subscriber_class, message)
        (@deliveries[subscriber_class] ||= []) << message
      end
    end
  end
end
