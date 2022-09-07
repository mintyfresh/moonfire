# frozen_string_literal: true

class LogUserEventsSubscriber < Moonfire::Subscriber
  subscribes_to User::Create, User::Update, User::Destroy

  def perform
    Rails.logger.info "User #{message.user.id} was #{message.class.name.demodulize.downcase}"
  end
end
