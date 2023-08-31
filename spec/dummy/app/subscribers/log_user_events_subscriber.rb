# frozen_string_literal: true

class LogUserEventsSubscriber < Moonfire::Subscriber
  subscribes_to User::CreateMessage, User::UpdateMessage, User::DestroyMessage

  def perform
    Rails.logger.info "User #{message.user.id} => #{message.class.name.demodulize}"
  end
end
