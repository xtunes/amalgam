module Amalgam
  class RegistrationsController < Amalgam::ApplicationController
    before_filter :authenticate_admin!
    layout 'amalgam/admin/login'

    def edit
      @resource = current_admin
      render :edit
    end

    def update
      @resource = current_admin
      respond_to do |format|
        format.html do
          if @resource.update_attributes(params[Amalgam.user_model.to_s.tableize.singularize])
            redirect_to amalgam.admin_root_url
          else
            render :edit
          end
        end
      end
    end
  end
end