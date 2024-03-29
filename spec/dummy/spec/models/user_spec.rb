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
require 'rails_helper'

RSpec.describe User do
  subject(:user) { build(:user) }

  it 'has a valid factory' do
    expect(user).to be_valid
  end

  it 'is invalid without a name' do
    user.name = nil
    expect(user).to be_invalid
  end

  it 'is invalid without an email' do
    user.email = nil
    expect(user).to be_invalid
  end

  it 'publishes a create message when created' do
    expect { user.save! }.to have_published(described_class, :create).with(user:)
  end

  it 'publishes an update message when updated' do
    user.save!
    expect { user.update!(name: 'New Name') }.to have_published(described_class, :update)
      .with(hash_including(:changes, user:))
  end

  it 'publishes a destroy message when destroyed' do
    user.save!
    expect { user.destroy! }.to have_published(described_class, :destroy)
      .with(hash_including(:changes, user:))
  end

  describe User::CreateMessage do
    it 'has subscribers' do
      expect(described_class).to have_subscribers
    end
  end

  describe User::UpdateMessage do
    it 'has subscribers' do
      expect(described_class).to have_subscribers
    end
  end

  describe User::DestroyMessage do
    it 'has subscribers' do
      expect(described_class).to have_subscribers
    end
  end
end
