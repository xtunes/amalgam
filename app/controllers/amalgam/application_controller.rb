module Amalgam
  class ApplicationController < ActionController::Base
    include Amalgam::Authorities::Controllers::Helpers
    include Amalgam::Globalize::Helpers if Amalgam.i18n
    protect_from_forgery
  end
end
