# frozen_string_literal: true

class LogOddUserEventsSubscriber < Moonfire::Subscriber
  subscribes_to User::CreateMessage, User::UpdateMessage, User::DestroyMessage do |message|
    # Only log for odd user IDs
    message.user.id.odd?
  end

  def perform
    Rails.logger.info "Odd User #{message.user.id} => #{message.class.name.demodulize}"
  end
end
