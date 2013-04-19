module Amalgam
  module Admin
    class AttrInputFormBuilder < ActionView::Helpers::FormBuilder
      include CollectiveIdea::Acts::NestedSet::Helper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::JavaScriptHelper
      def attr_input(attribute, options={})
        if !object.class.included_modules.include?(Amalgam::Types::Hierachical) && attribute.to_s == object.class.foreign_key.to_s
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

      def tag_input(attribute, options = {})
        options[:class] ||= ''
        options[:class] += " #{attribute.to_s}"
        options[:default_text] ||= 'add a tag'
        options[:min_chars] ||= 0
        options[:width] ||= '300px'
        options[:height] ||= '100px'
        options[:placeholder_color] ||= '#666666'
        html = text_area(attribute, options)
        js_string = %Q{$(function(){$('.#{attribute.to_s}').tagsInput({interactive:true,defaultText:'#{options[:default_text]}',minChars: #{options[:min_chars]},width:'#{options[:width]}',height:'#{options[:height]}',autocomplete: {selectFirst: false },'hide':true,'delimiter':',','unique':true,removeWithBackspace:true,placeholderColor:'#{options[:placeholder_color]}',autosize: true,comfortZone: 20,inputPadding: 6*2});});}
        html += javascript_tag(js_string)
        html.html_safe
      end
    end
  end
end