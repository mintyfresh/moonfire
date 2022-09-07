# frozen_string_literal: true

module Moonfire
  module DeliveryMethod
    autoload :ActiveJob, 'moonfire/delivery_method/active_job'
    autoload :Inline, 'moonfire/delivery_method/inline'
  end
end
