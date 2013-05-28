# encoding: UTF-8
module Amalgam
  module Types
    module Controllers
      module Filters
        extend ActiveSupport::Concern

        included do
          before_filter :find_model_class
          before_filter :get_resource, :except => [:index]
          before_filter :get_collection, :only => [:index]
          layout :resources_layout
        end

        protected

        def collection
          @collection
        end

        def model_name
          request.env[:resources].singularize.to_sym
        end

        def resource
          @resource
        end

        def update_resource
          lang = I18n.locale
          I18n.locale = params[:locale] if Amalgam.i18n && params[:locale]
          unless resource.source.class.attr_accessible[Amalgam.admin_access_attr_as].empty?
            resource.update_attributes(params[model_name], :as => Amalgam.admin_access_attr_as)
          else
            resource.update_attributes(params[model_name])
          end
          I18n.locale = lang
        end

        def find_model_class
          params[:resources] ||= request.env[:resources]
          @resource_class = params[:resources].classify.constantize
        end

        def get_resource
          lang = I18n.locale
          I18n.locale = params[:locale] if Amalgam.i18n && params[:locale]
          if params[:id]
            @resource ||= @resource_class.find(params[:id])
          else
            unless params[:parent_class]
              if @resource_class.attr_accessible[Amalgam.admin_access_attr_as].empty?
                @resource ||= @resource_class.new(params[model_name])
              else
                @resource ||= @resource_class.new(params[model_name], :as => Amalgam.admin_access_attr_as)
              end
            else
              if @resource_class.attr_accessible[Amalgam.admin_access_attr_as].empty?
                 @resource ||= params[:parent_class].safe_constantize.find(params[:parent_id]).send(request.env[:resources].to_s.tableize).new(params[model_name])
              else
                 @resource ||= params[:parent_class].safe_constantize.find(params[:parent_id]).send(request.env[:resources].to_s.tableize).new(params[model_name], :as => Amalgam.admin_access_attr_as)
              end
            end
          end
          @back_path = admin_resources_path(request.env[:resources])
          @resource = Amalgam::Admin::ResourceDecorator.decorate(@resource)
          I18n.locale = lang
        end

        def get_collection
          if @resource_class.included_modules.include?(Amalgam::Types::Hierachical)
            @collection = @resource_class.all
          else
            if params[:parent_class]
              @collection = params[:parent_class].safe_constantize.find(params[:parent_id]).send(@resource_class.to_s.tableize).page(params[:page])
            else
              @collection = @resource_class.page(params[:page])
            end
          end
          @collection = Amalgam::Admin::ResourceDecorator.decorate_collection(@collection)
        end

        def resources_layout
          layout = request.headers['X-PJAX'] ? false : "amalgam/admin/application"
        end
      end
    end
  end
end