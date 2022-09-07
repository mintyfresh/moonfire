# frozen_string_literal: true

module Moonfire
  class Message
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
  end
end
