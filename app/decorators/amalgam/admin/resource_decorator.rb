module Amalgam
  module Admin
    class ResourceDecorator < ::Draper::Decorator

      class << self
        def decorate(source, options = {})
          obj = super(source, options)
          source.class.included_modules.select{|x| x.to_s.match(/^Amalgam::Types::/)}.each do |type_class|
            obj.extend "#{type_class.to_s}::Decorator".safe_constantize if source.class.qualified_const_defined?("#{type_class.to_s}::Decorator")
          end
          obj
        end
      end

      delegate_all

      def to_param
        source.id
      end

      def admin_attrs
        list = []
        if source.class.respond_to?(:admin_attrs)
          return source.class.admin_attrs
        else
          if source.class.attr_accessible[Amalgam.admin_access_attr_as].present?
            list = source.class.attr_accessible[Amalgam.admin_access_attr_as].to_a
          else
            list = source.class.attr_accessible[:default].to_a
          end
        end
        amalgam_remove_attr(list)
        list
      end

      protected

      def amalgam_remove_attr(attrs)
        attrs.delete("")
      end
    end
  end
end