module Amalgam
  class RegistrationsController < Amalgam::ApplicationController
    before_filter :get_resource_name, :only => [:update,:edit]
    before_filter :authenticate_scope!, :only => [:edit, :update]
    layout 'amalgam/admin/login'

    def edit
      render :edit
    end

    def update
      respond_to do |format|
        format.html do
          if @resource.update_attributes(params[resource_name])
            redirect_to after_update_path_for(@resource)
          else
            render :edit
          end
        end
      end
    end

    private

    def authenticate_scope!
      send(:"authenticate_#{params[:resource] || resource_name}!")
      @resource = send(:"current_#{params[:resource] || resource_name}")
    end

    def get_resource_name
      build_resource(params,false)
    end
  end
end