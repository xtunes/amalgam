module Amalgam
  class ApplicationController < ActionController::Base

    protected

    def authenticate_admin!
    	true
    end

    def admin_signed_in?
    	true
    end
  end
end
