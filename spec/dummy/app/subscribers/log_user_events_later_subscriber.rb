# frozen_string_literal: true

class LogUserEventsLaterSubscriber < Moonfire::Subscriber
  subscribes_to User::Create, User::Update, User::Destroy

  self.delivery_method = :active_job, { wait: 10.seconds }

  def perform
    Rails.logger.info "User #{message.user.id} => #{message.class.name.demodulize}"
  end
end
