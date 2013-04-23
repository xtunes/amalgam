module Amalgam
  module Admin
    module ResourcesHelper
      def list_attrs(resource_class)
        list = []
        unless resource_class.attr_accessible[Amalgam.admin_access_attr_as].empty?
          list += resource_class.attr_accessible[Amalgam.admin_access_attr_as].to_a.clone
        else
          list += resource_class.attr_accessible[:default].to_a.clone
        end
        list = list - [""]
        list = list - ["parent_id", "left_id", "right_id"] if resource_class.included_modules.include?(Amalgam::Types::Hierachical)
        list = list - ["identity"] if resource_class.included_modules.include?(Amalgam::Types::Page)
        list = list - ["attachments_attributes"] if resource_class.included_modules.include?(Amalgam::Types::Attachable)
        list = list - resource_class.tag_types.map{|x| "#{x.to_s.singularize}_list"} if resource_class.included_modules.include?(Amalgam::Types::Taggable)
        list
      end
    end
  end
end