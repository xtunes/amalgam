class ApplicationController < ActionController::Base
  include Amalgam::Authorities::Controllers::Helpers
  include Amalgam::Globalize
  protect_from_forgery
end
