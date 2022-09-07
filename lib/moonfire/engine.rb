# frozen_string_literal: true

begin
  require 'factory_bot_rails'
  require 'faker'
rescue LoadError
  # Optional dependencies
end

module Moonfire
  class Engine < ::Rails::Engine
    isolate_namespace Moonfire
  end
end
