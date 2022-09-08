# frozen_string_literal: true

module Moonfire
  module DeliveryMethod
    autoload :ActiveJob, 'moonfire/delivery_method/active_job'
    autoload :Inline, 'moonfire/delivery_method/inline'

    # @param locator [Symbol, Class, nil]
    # @param options [Hash]
    # @return [#deliver]
    def self.resolve(locator, **options)
      case locator
      when Class
        locator.new(**options)
      when Symbol
        const_get(locator.to_s.camelize).new(**options)
      when nil
        Inline.new
      else
        raise ArgumentError, "Unknown delivery method: #{locator.inspect}"
      end
    end
  end
end
