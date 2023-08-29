# frozen_string_literal: true

module Moonfire
  module Model
    extend ActiveSupport::Concern

    class_methods do
      # @param event_name [Symbol]
      # @param class_name [String]
      # @return [void]
      def define_moonfire_message(event_name, class_name: event_name.to_s.camelize, &)
        if const_defined?(class_name)
          message_class = const_get(class_name)
        else
          message_class = const_set(class_name, Class.new(Moonfire::Message))
          message_class.attribute(model_name.singular.to_sym)
        end

        message_class.class_eval(&) if block_given?
      end
    end

    included do
      define_moonfire_message :create
      define_moonfire_message :update do
        attribute :changes
      end
      define_moonfire_message :destroy do
        attribute :changes
      end

      after_create_commit :publish_record_create
      after_update_commit :publish_record_update
      after_destroy_commit :publish_record_destroy
    end

  private

    # @return [void]
    def publish_record_create
      self.class::Create.publish(
        model_name.singular.to_sym => self,
        message_bus: moonfire_message_bus
      )
    end

    # @return [void]
    def publish_record_update
      self.class::Update.publish(
        model_name.singular.to_sym => self,
        changes:     saved_changes,
        message_bus: moonfire_message_bus
      )
    end

    # @return [void]
    def publish_record_destroy
      self.class::Destroy.publish(
        model_name.singular.to_sym => self,
        changes:     saved_changes,
        message_bus: moonfire_message_bus
      )
    end

    # @return [Moonfire::MessageBus]
    def moonfire_message_bus
      Moonfire.message_bus
    end
  end
end
