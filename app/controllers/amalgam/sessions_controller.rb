module Amalgam
  class SessionsController < Amalgam::ApplicationController
    layout 'amalgam/admin/login'

    def new
      @resource = Amalgam.user_model.new
    end

    def create
      @resource = Amalgam.user_model.authenticate params[Amalgam.user_model.to_s.tableize.singularize][:login], params[Amalgam.user_model.to_s.tableize.singularize][:password]
      if @resource && @resource.admin?
        login_as(@resource)
        redirect_back_or_default params[:return_to] || redirect_after_signin(@resource)
      else
        redirect_to signin_url, :alert => I18n.t('amalgam.sessions.fail.invalid_name_or_password')
      end
    end

    def destroy
      logout
      redirect_to redirect_after_siginout, :notice => I18n.t('amalgam.sessions.success.sign_out')
    end
  end
end