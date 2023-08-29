# frozen_string_literal: true

RSpec::Matchers.define :have_published do |expected_class|
  match do |block|
    initial_count = message_bus.messages.count
    block.call

    @published_count = message_bus.messages[initial_count..].count do |message|
      result = message.instance_of?(expected_class)

      if defined?(@expected_attributes)
        result &&= values_match?(@expected_attributes, message.attributes.with_indifferent_access)
      end

      result
    end

    @published_count.in?(@expected_range ||= (1..))
  end

  chain :with do |attributes|
    @expected_attributes = attributes
  end

  chain :exactly do |count|
    @expectation_message = "exactly #{count} time#{'s' if count != 1}"
    @expected_range      = count..count
  end

  chain :at_least do |count|
    @expectation_message = "at least #{count} time#{'s' if count != 1}"
    @expected_range      = count..
  end

  chain :at_most do |count|
    @expectation_message = "at most #{count} time#{'s' if count != 1}"
    @expected_range      = ..count
  end

  chain :once do
    @expectation_message = 'exactly once'
    @expected_range = 1..1
  end

  chain :twice do
    @expectation_message = 'exactly twice'
    @expected_range = 2..2
  end

  chain :at_least_once do
    @expectation_message = 'at least once'
    @expected_range = 1..
  end

  chain :at_most_once do
    @expectation_message = 'at most once'
    @expected_range = ..1
  end

  chain :at_least_twice do
    @expectation_message = 'at least twice'
    @expected_range = 2..
  end

  chain :at_most_twice do
    @expectation_message = 'at most twice'
    @expected_range = ..2
  end

  failure_message do |block|
    message  = "expected { #{block_source(block)} } to publish #{expected_class}"
    message += " with #{@expected_attributes}" if defined?(@expected_attributes)
    message += " #{@expectation_message}" if defined?(@expectation_message)
    message += ", but published #{@published_count} time#{'s' if @published_count != 1}"

    message
  end

  def supports_block_expectations?
    true
  end

private

  def message_bus
    @message_bus ||= Moonfire.message_bus.tap do |message_bus|
      raise TypeError, <<~ERROR.strip unless message_bus.is_a?(Moonfire::RSpec::TestMessageBus)
        Moonfire.message_bus must be an instance of Moonfire::RSpec::TestMessageBus to the `have_published` matcher.
        You should add the following line to your environment/test.rb file:
        \trequire 'moonfire/rspec'
        \tconfig.moonfire.message_bus = Moonfire::RSpec::TestMessageBus.new
      ERROR
    end
  end

  def block_source(block)
    RSpec::Expectations::BlockSnippetExtractor.try_extracting_single_line_body_of(block, 'expect')
  end
end
