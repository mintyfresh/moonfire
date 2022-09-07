# frozen_string_literal: true

RSpec::Matchers.define :accept do |message|
  match do |subscriber_class|
    subscriber_class.accepts?(message)
  end

  failure_message do |subscriber_class|
    "expected #{subscriber_class} to accept #{message}"
  end

  failure_message_when_negated do |subscriber_class|
    "expected #{subscriber_class} not to accept #{message}"
  end
end
