# frozen_string_literal: true

module Moonfire
  module Model
    extend ActiveSupport::Concern

    class_methods do
      # @param event_name [Symbol]
      # @param class_name [String]
      # @return [void]
      def define_moonfire_message(event_name, class_name: event_name.to_s.camelize, &)
        message_class = const_set(class_name, Class.new(Moonfire::Message))
        message_class.attribute(model_name.singular.to_sym, required: true)
        message_class.class_eval(&) if block_given?
      end
    end

    included do
      include Moonfire::Publisher

      define_moonfire_message :create
      define_moonfire_message :update do
        attribute :changes, required: true
      end
      define_moonfire_message :destroy do
        attribute :changes, required: true
      end

      after_create_commit :publish_record_create
      after_update_commit :publish_record_update
      after_destroy_commit :publish_record_destroy
    end

  private

    # @return [void]
    def publish_record_create
      publish self.class::Create.new(model_name.singular.to_sym => self)
    end

    # @return [void]
    def publish_record_update
      publish self.class::Update.new(model_name.singular.to_sym => self, changes: saved_changes)
    end

    # @return [void]
    def publish_record_destroy
      publish self.class::Destroy.new(model_name.singular.to_sym => self, changes: saved_changes)
    end
  end
end
