module Amalgam
  class SessionsController < Amalgam::ApplicationController
    layout 'amalgam/admin/login'

    def new
      @name = params[:resource]
      @resource = params[:resource].classify.safe_constantize.new
    end

    def create
      @resource = build_resource(params)
      @resource = @resource.class.authenticate params[resource_name][:login], params[resource_name][:password]
      if @resource && @resource.admin?
        session["#{resource_name}_id".to_sym] = @resource.id
        redirect_back_or_default params[:return_to] || admin_root_url
      else
        if @resource
          session["#{resource_name}_id".to_sym] = @resource.id
          redirect_back_or_default params[:return_to] || main_app.root_url
        else
          redirect_to eval("#{resource_name}_signin_url"), :alert => I18n.t('amalgam.sessions.fail.invalid_name_or_password')
        end
      end
    end

    def destroy
      Rails.logger.info session
      session["#{params[:resource].to_s}_id".to_sym] = nil if params[:resource]
      redirect_to main_app.root_url, :notice => I18n.t('amalgam.sessions.success.sign_out')
    end
  end
end