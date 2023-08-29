# frozen_string_literal: true

module Moonfire
  module ErrorMode
    # Errors raised by subscribers are silently ignored and discarded.
    IGNORE = :ignore

    # Errors raised by subscribers are logged as warnings.
    # This is the default error mode.
    WARN = :warn

    # Errors bubble-up immediately, interrupting delivery to other subscribers.
    # The first error raised is the one that is raised to the caller.
    RAISE_FIRST = :raise_first

    # Errors bubble-up after all subscribers have been called.
    # The last error raised is the one that is raised to the caller.
    RAISE_LAST = :raise_last

    # @return [Array<Symbol>]
    def self.all
      @all ||= [IGNORE, WARN, RAISE_FIRST, RAISE_LAST].freeze
    end
  end
end
