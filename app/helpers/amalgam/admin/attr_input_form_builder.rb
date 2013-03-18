module Amalgam
  module Admin
    class AttrInputFormBuilder < ActionView::Helpers::FormBuilder
      include CollectiveIdea::Acts::NestedSet::Helper
      def attr_input(attribute, options={})
        if !object.class.included_modules.include?(Amalgam::Types::Hierachical) && attribute.to_s == object.class.foregin_key.to_s
          return select attribute, nested_set_options(object.class.parent_class_name.safe_constantize) {|i, level| "#{'-' * level} #{i.title}" },{:required => true}
        end
        column = object.class.columns.select{|m| m.name == attribute.to_s}.first
        case column.type
        when :integer
          options[:type] ||= 'number'
          return text_field(attribute,options)
        when :string
          return text_field(attribute,options)
        when :text
          return text_area(attribute,options)
        when :datetime
          return text_field attribute, value: object.send(attribute).nil? ? '' : object.send(attribute).strftime("%Y-%m-%d"), "data-widget"=>"datepicker"
        end
      end
    end
  end
end