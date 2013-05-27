require 'amalgam/globalize/helpers'
class ApplicationController < ActionController::Base
  include Amalgam::Globalize::Helpers
  protect_from_forgery
end
