# frozen_string_literal: true

module Moonfire
  module Model
    module ClassMethods
      BUILT_IN_EVENTS = %i[create update destroy].freeze

      def inherited(klass)
        super(klass)
        klass.moonfire_messages.merge!(moonfire_messages)
      end

      # @return [Hash{Symbol => String}]
      def moonfire_messages
        @moonfire_messages ||= Hash.new { |hash, key| hash[key] = "#{key.to_s.camelize}Message" }
      end

      # Declares or extends a message class to be published by the current model.
      #
      # @param event_name [Symbol] the name of the event to publish
      # @param attribute_names [Array<Symbol>] additional attributes to declare on the message
      # @param class_name [String] the class name to assign to the message
      # @return [void]
      def define_moonfire_message(event_name, *attribute_names, class_name: moonfire_messages[event_name], &)
        if const_defined?(class_name)
          message_class = const_get(class_name)
        else
          message_class = const_set(class_name, Class.new(Moonfire::Message))
          message_class.attribute(base_class.model_name.singular.to_sym)
        end

        attribute_names.each do |attribute_name|
          message_class.attribute(attribute_name)
        end

        message_class.class_eval(&) if block_given?
      end

      # Looks up the message class for the given event.
      #
      # @param event_name [Symbol]
      # @return [Class<Moonfire::Message>]
      # @raise [ArgumentError] if no event is defined for the given name
      def lookup_message_class_for_event(event_name)
        class_name = moonfire_messages.fetch(event_name) do
          raise ArgumentError, "Invalid name: #{event_name.inspect} (expected one of #{moonfire_messages.keys.inspect})"
        end

        const_get(class_name)
      end

      # @param event_name [Symbol]
      # @param mapping [Hash{Symbol => Symbol}] additional attributes to set on the message, mapped to model attributes
      # @param on_error [Proc] called when an error occurs while publishing the message
      # @return [void]
      def publishes_message(event_name, mapping: {}, on_error: nil, **, &)
        define_moonfire_message(event_name, *mapping.keys)
        after_commit(:"publish_record_#{event_name}", **)

        if block_given?
          define_method(:"publish_record_#{event_name}", &)
        else
          define_method(:"publish_record_#{event_name}") do
            attributes = mapping.transform_values { |value| send(value) }
            publish_message(event_name, **attributes, &on_error)
          end
        end
      end

      # Declares a `CreateMessage` to be published after creation of the record is committed.
      #
      # @param mapping [Hash{Symbol => Symbol}] additional attributes to set on the message, mapped to model attributes
      # @return [void]
      def publishes_message_on_create(mapping: {}, **, &)
        publishes_message(:create, mapping:, **, on: :create, &)
      end

      # Declares an `UpdateMessage` to be published after an update to the record is committed.
      # By default, the message will only be published if any attributes have changed.
      #
      # Includes a `changes` attribute on the message, sources from the `saved_changes` attribute on the record.
      #
      # @param mapping [Hash{Symbol => Symbol}] additional attributes to set on the message, mapped to model attributes
      # @return [void]
      def publishes_message_on_update(if: :saved_changes?, mapping: { changes: :saved_changes }, **, &)
        publishes_message(:update, mapping:, **, if:, on: :update, &)
      end

      # Declares an `DestroyMessage` to be published after deletion of the record is committed.
      # Includes a `changes` attribute on the message, sources from the `saved_changes` attribute on the record.
      #
      # @param mapping [Hash{Symbol => Symbol}] additional attributes to set on the message, mapped to model attributes
      # @return [void]
      def publishes_message_on_destroy(mapping: { changes: :saved_changes }, **, &)
        publishes_message(:destroy, mapping:, **, on: :destroy, &)
      end

      # @param events [Array<Symbol>]
      # @return [void]
      def publishes_messages_on(*events, **options) # rubocop:disable Style/ArgumentsForwarding
        events.each do |event|
          BUILT_IN_EVENTS.include?(event) or
            raise ArgumentError, "invalid event: #{event.inspect} (expected one of #{BUILT_IN_EVENTS.inspect})"

          send(:"publishes_message_on_#{event}", **options) # rubocop:disable Style/ArgumentsForwarding
        end
      end
    end
  end
end
