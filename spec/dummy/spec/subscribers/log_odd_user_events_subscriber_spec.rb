# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LogOddUserEventsSubscriber, type: :subscriber do
  subject(:subscriber) { described_class.new(message) }

  it 'accepts user create messages' do
    message = User::CreateMessage.new(user: build(:user, id: 1))
    expect(described_class).to accept(message)
  end

  it 'does not accept user create messages for even user IDs' do
    message = User::CreateMessage.new(user: build(:user, id: 2))
    expect(described_class).not_to accept(message)
  end

  it 'accepts user update messages' do
    message = User::UpdateMessage.new(user: build(:user, id: 1))
    expect(described_class).to accept(message)
  end

  it 'does not accept user update messages for even user IDs' do
    message = User::UpdateMessage.new(user: build(:user, id: 2))
    expect(described_class).not_to accept(message)
  end

  it 'accepts user destroy messages' do
    message = User::DestroyMessage.new(user: build(:user, id: 1))
    expect(described_class).to accept(message)
  end

  it 'does not accept user destroy messages for even user IDs' do
    message = User::DestroyMessage.new(user: build(:user, id: 2))
    expect(described_class).not_to accept(message)
  end

  describe '#perform' do
    subject(:perform) { subscriber.perform }

    before(:each) do
      allow(Rails.logger).to receive(:info)
    end

    it 'is called when a user is created' do
      user = create(:user)
      expect(User::CreateMessage).to have_been_delivered_to(described_class).with(user:)
    end

    it 'is called when a user is updated' do
      user = create(:user)
      user.update!(name: 'New Name')
      expect(User::UpdateMessage).to have_been_delivered_to(described_class).with(hash_including(:changes, user:))
    end

    it 'is called when a user is destroyed' do
      user = create(:user)
      user.destroy!
      expect(User::DestroyMessage).to have_been_delivered_to(described_class).with(hash_including(:changes, user:))
    end

    context 'with a user create message' do
      let(:message) { User::CreateMessage.new(user: build(:user, id: 1)) }

      it 'logs the message' do
        perform
        expect(Rails.logger).to have_received(:info).with('Odd User 1 => CreateMessage')
      end
    end

    context 'with a user update message' do
      let(:message) { User::UpdateMessage.new(user: build(:user, id: 1)) }

      it 'logs the message' do
        perform
        expect(Rails.logger).to have_received(:info).with('Odd User 1 => UpdateMessage')
      end
    end

    context 'with a user destroy message' do
      let(:message) { User::DestroyMessage.new(user: build(:user, id: 1)) }

      it 'logs the message' do
        perform
        expect(Rails.logger).to have_received(:info).with('Odd User 1 => DestroyMessage')
      end
    end
  end
end
