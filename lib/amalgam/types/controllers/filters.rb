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
        end

        protected

        def collection
          @collection
        end

        def model_name
          params[:resources].singularize.to_sym
        end

        def resource
          @resource
        end

        def update_resource
          resource.update_attributes(params[model_name], :as => Amalgam.admin_access_attr_as)
        end

        def find_model_class
          @resource_class = params[:resources].classify.constantize
        end

        def get_resource
          if params[:id]
            @resource ||= @resource_class.find(params[:id])
          else
            @resource ||= @resource_class.new(params[model_name], :as => Amalgam.admin_access_attr_as)
          end
          if @resource_class.included_modules.include?(Amalgam::Types::Seo)
            @resource.define_singleton_method(:to_param) do
              self.id
            end
          end
        end

        def get_collection
          if @resource_class.included_modules.include?(Amalgam::Types::Hierachical)
            @collection = @resource_class.all
          else
            @collection = @resource_class.page(params[:page])
          end
        end
      end
    end
  end
end