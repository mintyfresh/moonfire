# frozen_string_literal: true

RSpec::Matchers.define :have_subscribers do
  match do |message_class|
    @subscribers = Moonfire.message_bus.subscribers_for(message_class)

    @subscribers.any?
  end

  failure_message do |message_class|
    "expected #{message_class} to have subscribers, but none were found"
  end

  failure_message_when_negated do |message_class|
    "expected #{message_class} not to have subscribers, but #{@subscribers.map(&:name).join(', ')} are subscribed"
  end
end
