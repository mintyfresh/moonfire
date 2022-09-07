# frozen_string_literal: true

module Moonfire
  class Message
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    # @param name [Symbol]
    # @param type [Symbol, nil]
    # @param required [Boolean]
    # @return [void]
    # @see ActiveModel::Attributes::ClassMethods#attribute
    def self.attribute(name, type = nil, required: false, **options)
      super(name, type, **options)
      validates(name, presence: required) if required
    end
  end
end
