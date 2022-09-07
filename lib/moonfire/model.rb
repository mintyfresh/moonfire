# frozen_string_literal: true

module Moonfire
  module Model
    extend ActiveSupport::Concern

    included do
      include Moonfire::Publisher

      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        # class Create < Moonfire::Message
        #   attribute :user, required: true
        # end
        class Create < Moonfire::Message
          attribute :#{model_name.singular}, required: true
        end

        # class Update < Moonfire::Message
        #   attribute :user, required: true
        # end
        class Update < Moonfire::Message
          attribute :#{model_name.singular}, required: true
        end

        # class Destroy < Moonfire::Message
        #   attribute :user, required: true
        # end
        class Destroy < Moonfire::Message
          attribute :#{model_name.singular}, required: true
        end
      RUBY

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
      publish self.class::Update.new(model_name.singular.to_sym => self)
    end

    # @return [void]
    def publish_record_destroy
      publish self.class::Destroy.new(model_name.singular.to_sym => self)
    end
  end
end
