# frozen_string_literal: true

require 'moonfire/version'
require 'moonfire/engine'

module Moonfire
  autoload :Message, 'moonfire/message'
  autoload :MessageBus, 'moonfire/message_bus'
  autoload :Model, 'moonfire/model'
  autoload :Publisher, 'moonfire/publisher'
  autoload :Subscriber, 'moonfire/subscriber'
end
