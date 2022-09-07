# frozen_string_literal: true

class User::Created < Moonfire::Message
  attribute :user, required: true
end
