# encoding: UTF-8
module Amalgam
  module Types
    module Controllers
      module Actions
        extend ActiveSupport::Concern

        included do
          respond_to :html, :js, :json
        end

        def index
          respond_with(collection)
        end

        def search
          @collection = @resource_class.search(params[:content],params[:page])
          @collection = Amalgam::Admin::ResourceDecorator.decorate_collection(@collection)
        end

        def show
          respond_with(resource)
        end

        def new
          respond_with(resource)
        end

        def edit
        end

        def create
          flash[:notice] = "#{model_name} was successfully created." if resource.save
          url = params[:locale] ? admin_resources_path(params[:resources],:anchor => "node-#{resource.id}", :locale => params[:locale]) : admin_resources_path(params[:resources],:anchor => "node-#{resource.id}")
          respond_with(resource, :location => url) do |formate|
            formate.json{ render :json => { :errors => resource.errors, :id => resource.id } }
          end
        end

        def update
          flash[:notice] = "#{model_name} was successfully updated." if update_resource
          url = params[:locale] ? admin_resources_path(params[:resources],:anchor => "node-#{resource.id}", :locale => params[:locale]) : admin_resources_path(params[:resources],:anchor => "node-#{resource.id}")
          respond_with(resource, :location => url) do |formate|
            formate.json{ render :json => { :errors => resource.errors } }
          end
        end

        def destroy
          resource.destroy
          url = params[:locale] ? admin_resources_path(params[:resources], :locale => params[:locale]) : admin_resources_path(params[:resources])
          respond_with(resource, :location => url) do |formate|
            formate.json{ render :json => { :errors => resource.errors } }
          end
        end
      end
    end
  end
end