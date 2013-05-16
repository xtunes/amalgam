module Amalgam
  class ApplicationController < ActionController::Base
#    include Amalgam::Globalize::Helpers if Amalgam.i18n
    protect_from_forgery

    protected

    def authenticate_admin!
      if !current_admin
        store_location
        redirect_to authentication_return_url, :alert => I18n.t('amalgam.sessions.fail.need_to_be_admin')
      end
    end

    def store_location(path = nil)
      session[:return_to] = path || request.fullpath
    end
  end
end
