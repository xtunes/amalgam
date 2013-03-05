module Amalgam
  module Editor::EditorHelper

    def editable_content_tag tag,obj,field,options={},&block
      if can_edit?
        options[:data] = (options[:data] || {}).merge(:type => 'editable')
        options[:data][:mercury] = "full"
        options[:data][:id] = "#{obj.class.to_s.tableize}/#{obj.id.to_s}.#{field.to_s}"
      end
      value = fetch_field(obj,field)
      if value.present?
        content_tag(tag,value.to_s.html_safe,options)
      else
        content_tag(tag,options,&block) if block_given?
      end
    end

    def editable_image_tag obj,field,options={}
      if can_edit?
        options[:data] = (options[:data] || {}).merge(:type => 'editable')
        options[:data][:mercury] = "image"
        options[:data][:id] = "#{obj.class.to_s.tableize}/#{obj.id.to_s}.#{field.to_s}"
        options[:data][:thumb] = options[:thumb]
      end
      value = fetch_field(obj,field)
      image_url = options.delete(:default) || '#'
      if value
        if options[:thumb]
          image_url = Amalgam::Models::Image.find(value.to_i).file.thumb(options[:thumb]).url
        else
          image_url = Amalgam::Models::Image.find(value.to_i).url
        end
        options[:data][:image_id] ||= value if can_edit?
      end
      image_tag(image_url.to_s.html_safe,options)
    end

    def properties_button(model_or_url,title=nil)
      return unless can_edit?
      title ||= I18n.t('properties_edit')
      url = case url
             when String then "#{model_or_url}?mercury_frame=true"
             else "#{url_for(model_or_url)}?mercury_frame=true"
            end
      button_tag(title, :type=>'button', :data => {:url => url }, :class => 'properties', :style => "display:none")
    end

    private
    def fetch_field obj,field
      list = field.to_s.split(".")
      node_tmp = obj
      while list.present?
        node = list.shift
        return node_tmp[node] if !list.present? || node_tmp[node] == nil
        node_tmp = node_tmp[node]
      end
    end
  end
end