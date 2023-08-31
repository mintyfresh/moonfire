# frozen_string_literal: true

module Moonfire
  module Model
    autoload :ClassMethods, 'moonfire/model/class_methods'

    def self.included(klass)
      super(klass)
      klass.extend(ClassMethods)
    end

  protected

    # @param event_name [Symbol]
    # @param attributes [Hash]
    # @yieldparam subscriber [Class<Moonfire::Subscriber>]
    # @yieldparam message [Moonfire::Message]
    # @yieldparam error [StandardError]
    # @yieldreturn [void]
    # @return [void]
    def publish_message(event_name, message_bus: default_message_bus, **, &)
      self.class.lookup_message_class_for_event(event_name)
        .publish(model_name.singular.to_sym => self, **, message_bus:, &)
    end

    # @return [Moonfire::MessageBus]
    def default_message_bus
      Moonfire.message_bus
    end
  end
end
