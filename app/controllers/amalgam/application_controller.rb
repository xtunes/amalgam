module Amalgam
  class ApplicationController < ActionController::Base
    include Amalgam::Authorities::Controllers::Helpers
    protect_from_forgery

    protected

    def redirect_back_or_default(default)
      if default || session[:return_to]
        redirect_to( session[:return_to] || default )
      else
        redirect_to root_url
      end
      session[:return_to] = nil
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def build_resource(params)
      Amalgam.authorities.each do |auth_name,type|
        if params[auth_name]
          self.resource_name = auth_name
          return auth_name.to_s.classify.constantize.new
        end
      end
    end

    def resource_name
      @resource_name
    end

    def resource_name=(name)
      @resource_name = name
    end
  end
end
