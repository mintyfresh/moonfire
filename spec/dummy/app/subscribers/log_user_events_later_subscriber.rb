# frozen_string_literal: true

class LogUserEventsLaterSubscriber < Moonfire::Subscriber
  subscribes_to User::Create, User::Update, User::Destroy

  self.delivery_method = Moonfire::DeliveryMethod::ActiveJob.new(wait: 10.seconds)

  def perform
    Rails.logger.info "User #{message.user.id} => #{message.class.name.demodulize}"
  end
end
