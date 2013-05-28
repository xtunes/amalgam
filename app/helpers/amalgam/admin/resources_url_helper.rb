module Amalgam
  module Admin
    module ResourcesUrlHelper
      def admin_new_resource_path(model,options={})
        send("new_admin_#{model.to_s.singularize}_path", options)
      end
      def admin_resource_path(model,id,options={})
        send("admin_#{model.to_s.singularize}_path", id,options)
      end
      def admin_resources_path(model,options={})
        send("admin_#{model.to_s}_path", options)
      end
      def admin_update_resource_path(model,id,options={})
        send("admin_#{model.to_s.singularize}_path", id,options)
      end
      def admin_edit_resource_path(model,id,options={})
        send("edit_admin_#{model.to_s.singularize}_path", id,options)
      end
      def admin_search_resources_url(model, options={})
        send("search_admin_#{model.to_s}_path", options)
      end
      def admin_create_resource_path(model,options={})
        send("admin_#{model.to_s}_path", options)
      end
    end
  end
end