# frozen_string_literal: true

Rails.application.routes.draw do
  mount Moonfire::Engine => '/moonfire'
end
