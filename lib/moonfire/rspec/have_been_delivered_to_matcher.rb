# frozen_string_literal: true

RSpec::Matchers.define :have_been_delivered_to do |subscriber_class|
  match do |message_class|
    @deliveries = message_bus.deliveries[subscriber_class] || []

    @deliveries = @deliveries
      .select { |message| message.is_a?(message_class) }
      .select { |message| @expected_attributes.nil? || values_match?(@expected_attributes, message.attributes) }

    @deliveries.any?
  end

  chain :with do |attributes|
    @expected_attributes = attributes.stringify_keys
  end

  failure_message do |message_class|
    message  = "expected #{message_class} to been delivered_to #{subscriber_class}"
    message += " with #{@expected_attributes}" if defined?(@expected_attributes)

    message
  end

  failure_message_when_negated do |message_class|
    message  = "expected #{message_class} not to been delivered_to #{subscriber_class}"
    message += " with #{@expected_attributes}" if defined?(@expected_attributes)

    message
  end

private

  def message_bus
    @message_bus ||= Moonfire.message_bus.tap do |message_bus|
      raise TypeError, <<~ERROR.strip unless message_bus.is_a?(Moonfire::RSpec::TestMessageBus)
        Moonfire.message_bus must be an instance of Moonfire::RSpec::TestMessageBus to the `have_been_delivered_to` matcher.
        You should add the following line to your environment/test.rb file:
        \trequire 'moonfire/rspec'
        \tconfig.moonfire.message_bus = Moonfire::RSpec::TestMessageBus.new
      ERROR
    end
  end
end
