# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  include Moonfire::Publisher

  validates :name, :email, presence: true

  after_create_commit do
    publish Created.new(user: self)
  end
end
