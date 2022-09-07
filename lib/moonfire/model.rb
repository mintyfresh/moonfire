# frozen_string_literal: true

module Moonfire
  module Model
    extend ActiveSupport::Concern

    included do
      include Moonfire::Publisher

      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        # class Created < Moonfire::Message
        #   attribute :user, required: true
        # end
        class Created < Moonfire::Message
          attribute :#{model_name.singular}, required: true
        end

        # class Updated < Moonfire::Message
        #   attribute :user, required: true
        # end
        class Updated < Moonfire::Message
          attribute :#{model_name.singular}, required: true
        end

        # class Destroyed < Moonfire::Message
        #   attribute :user, required: true
        # end
        class Destroyed < Moonfire::Message
          attribute :#{model_name.singular}, required: true
        end
      RUBY

      after_create_commit :publish_record_created
      after_update_commit :publish_record_updated
      after_destroy_commit :publish_record_destroyed
    end

  private

    # @return [void]
    def publish_record_created
      publish self.class::Created.new(model_name.singular.to_sym => self)
    end

    # @return [void]
    def publish_record_updated
      publish self.class::Updated.new(model_name.singular.to_sym => self)
    end

    # @return [void]
    def publish_record_destroyed
      publish self.class::Destroyed.new(model_name.singular.to_sym => self)
    end
  end
end
