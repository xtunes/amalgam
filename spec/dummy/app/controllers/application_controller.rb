class ApplicationController < ActionController::Base
  include Amalgam::Globalize
  protect_from_forgery
end
