module Amalgam
  module Editor::PropertiesBuilderHelper
    include Mercury::Authentication
    def properties_for(record, options = {}, &proc)
      return unless can_edit?
      defaults = {
        :builder => PropertyFormBuilder,
        :url => amalgam.admin_editor_path,
        :method => :put,
        :remote => true,
        :html => { :style => 'width:450px;padding-bottom:30px;' }
      }

      options.reverse_merge!(defaults)
      form = form_for(record,options) do |f|
        yield(f)
        concat('<hr/>'.html_safe)
        concat(f.submit(:class => 'btn btn-primary'))
      end
      content_tag(:script, form , :type => "text/html" ,:id => "property-form-#{record.class.to_s.downcase}-#{record.id}", :class => params[:type] || 'default' )
    end

    class PropertyFormBuilder < ActionView::Helpers::FormBuilder

      def string(attribute, options={})
        field_with_label(:text_field,attribute,options)
      end

      def text(attribute, options={})
        field_with_label(:text_area,attribute,options)
      end

      def attachment(name, options={})
        options[:class] ||= 'input-xlarge'
        index_create
        obj = object.attachments[name]
        @buffer = label("#{I18n.t('amalgam.attachment')} : #{name}",options.delete(:lable_options)||{:style => 'font-weight:bold;'})
        @buffer.concat '<div style = "border-bottom: solid #cccccc 1px;padding:5px; margin-bottom:3px;">'.html_safe
        obj.attachment_settings[:store_accessors].each do |accessor|
          @buffer.concat label(I18n.t("activerecord.attributes.#{obj.first.class.to_s.underscore}.#{accessor}")+':',:style => "display:inline;margin-right:35px;")
          @buffer.concat attachment_field(:text_field, accessor, obj.send(accessor), options)
          @buffer.concat '<br>'.html_safe
        end
        @buffer.concat label(I18n.t("amalgam.file_upload")+':',:style => "display:inline;margin-right:10px;")
        @buffer.concat attachment_field(:file_field, :file)
        @buffer.concat '<br>'.html_safe
        if obj.try(:content_type).to_s =~ /image/
          @buffer.concat label(I18n.t("amalgam.file_pre")+':',:style => "display:inline;margin-right:10px;")
          @buffer.concat @template.image_tag("/attachments/#{obj.id}?thumb=true")
        else
          @buffer.concat "<a href= '#{obj.file.try(:url)}'>#{I18n.t("amalgam.file_download")}</a>".html_safe if obj
        end
        @buffer.concat attachment_field(:hidden_field, :name, name)
        @buffer.concat attachment_field(:hidden_field, :id, obj.id) if obj.try(:persisted?)
        @buffer.concat '</div>'.html_safe
        @buffer.html_safe
      end

      def attachment_list(name, options={})
        options[:class] ||= "attachment_list_#{name}"
        @buffer = @template.content_tag(:div,options) do
          buffer = label("#{I18n.t('amalgam.attachment_list')} : #{name}",options.delete(:lable_options)||{:style => 'font-weight:bold;'})
          objs = object.attachments[name] || []
          objs.each do |obj|
            buffer.concat attachment_item(obj).html_safe
          end
          buffer
        end

        link = @template.link_to('#', :class => 'new_attachment', :name => name, :data => {"model-id" => object.id, "type" => object.class.to_s.underscore}) do
          "<i class=\"icon-plus\"></i>#{::I18n.t('amalgam.admin.actions.new')}".html_safe
        end
        @buffer.concat link
      end

      protected

      def attachment_item(attachment)
        index_create
        @template.content_tag(:div) do
          buffer = '<div style = "border-bottom: solid #cccccc 1px;padding:5px; margin-bottom:3px;">'.html_safe
          attachment.attachment_settings[:store_accessors].each do |accessor|
            buffer.concat label(I18n.t("activerecord.attributes.#{attachment.class.to_s.underscore}.#{accessor}")+':',:style => "display:inline;margin-right:35px;")
            buffer.concat attachment_field(:text_field, accessor, attachment.send(accessor), {})
            buffer.concat '<br>'.html_safe
          end
          buffer.concat label(I18n.t("amalgam.file_upload")+':',:style => "display:inline;margin-right:10px;")
          buffer.concat attachment_field(:file_field, :file)
          buffer.concat destroy_field(attachment)
          buffer.concat '<br>'.html_safe
          if attachment.try(:content_type).to_s =~ /image/
            buffer.concat label(I18n.t("amalgam.file_pre")+':',:style => "display:inline;margin-right:10px;")
            buffer.concat @template.image_tag("/attachments/#{attachment.id}?thumb=true")
          else
            buffer.concat "<a href= '#{attachment.file.try(:url)}'>#{I18n.t("amalgam.file_download")}</a>".html_safe if attachment
          end
          buffer.concat attachment_field(:hidden_field, :name, attachment.name)
          buffer.concat attachment_field(:hidden_field, :id, attachment.id) if attachment.try(:persisted?)
          buffer.concat '</div>'.html_safe
          buffer.html_safe
        end
      end

      private

      def field_with_label(type,attribute,options)
        label(attribute,options.delete(:lable_options)||{}) + field(type,attribute,options)
      end

      def field(type,attribute,options)
        add_default_name(attribute,options)
        if(attribute.to_s.include?('.'))
          val = attribute.split('.').unshift(object).reduce do |value,key|
            value[key]
          end
          options[:value] = val
        end
        self.send(type,attribute,options)
      end

      def attachment_field(type,field,value = nil,options={})
        options[:name] = name_for_attribute('attachments_attributes') + "[#{@index}][#{field.to_s}]"
        options[:value] = value
        self.send(type,"attachment.#{field}",options)
      end

      def destroy_field(attachment,options={})
        name = name_for_attribute('attachments_attributes') + "[#{@index}][_destroy]"
        buffer = @template.check_box_tag name
        buffer.concat ::I18n.t('amalgam.admin.actions.destroy')
        buffer
      end

      def add_default_name(attribute,options)
        options[:name] ||= name_for_attribute(attribute)
      end

      def name_for_attribute(attribute)
        "[content][#{object.class.to_s.tableize}/#{object.id.to_s}.#{attribute.to_s}][value]"
      end

      def index_create
        @index = SecureRandom.uuid
      end
    end
  end
end