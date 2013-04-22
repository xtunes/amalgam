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
      options[:display] ||= '300x300'
      if can_edit?
        options[:data] = (options[:data] || {}).merge(:type => 'editable')
        options[:data][:mercury] = "image"
        options[:data][:id] = "#{obj.class.to_s.tableize}/#{obj.id.to_s}.#{field.to_s}"
        options[:data][:thumb] = options[:display]
      end
      value = fetch_field(obj,field)
      options[:placeholder] ||= :dummyimage
      options[:placeholder_options] ||= {}
      if options[:placeholder].is_a?(String) && !value
        if options[:display]
          options[:width] ||= options[:display].match(/(\d*)(x|X)$/)[1] if options[:display].match /(\d*)(x|X)$/
          options[:height] ||= options[:display].match(/^(x|X)(\d*)/)[2] if options[:display].match /^(x|X)(\d*)/
          if options[:display].match /(\d*)(X|x)(\d*)/
            options[:width] ||= options[:display].match(/(\d*)(X|x)(\d*)/)[1]
            options[:height] ||= options[:display].match(/(\d*)(X|x)(\d*)/)[3]
          end
        end
        options[:width] ||= options[:placeholder_options][:width]
        options[:height] ||= options[:placeholder_options][:height]
      end
      options[:placeholder_options][:bg_color] ||= 456
      options[:placeholder_options][:front_color] ||= 'fff'
      options[:placeholder_options][:width] ||= (options[:width] || 300)
      options[:placeholder_options][:height] ||= (options[:height] || 400)
      options[:placeholder_options][:text] ||= "#{options[:placeholder_options][:width]}X#{options[:placeholder_options][:height]}"
      image_url = case options[:placeholder]
      when String
        then options[:placeholder].match(/^(http:\/\/)|^(https:\/\/)/) ? options[:placeholder] : image_path(options[:placeholder])
      when Symbol
        then
          if options[:display] && options[:display].match(/\d*(X|x)\d*/)
            "http://dummyimage.com/#{options[:display].match(/\d*(X|x)\d*/).to_s}/#{options[:bg_color]}/#{options[:front_color]}.gif&text=#{options[:placeholder_options][:text]}"
          else
            "http://dummyimage.com/#{options[:placeholder_options][:width]}x#{options[:placeholder_options][:height]}/#{options[:bg_color]}/#{options[:front_color]}.gif&text=#{options[:placeholder_options][:text]}"
          end
      end
      options.delete(:placeholder)
      options.delete(:placeholder_options)
      if value
        if options[:display]
          image_url = Amalgam::Models::Image.find(value.to_i).file.thumb(options[:display]).url
        else
          image_url = Amalgam::Models::Image.find(value.to_i).url
        end
        options[:data][:image_id] ||= value if can_edit?
      end
      options.delete(:display)
      image_tag(image_url.to_s.html_safe,options)
    end

    def properties_button(record,title=nil,&block)
      return unless can_edit?
      title ||= I18n.t('amalgam.properties_edit')
      content = button_tag(title, :type=>'button', :data => {:id => "#{record.class.to_s.downcase}-#{record.id}" }, :class => 'properties', :style => "display:none")
      if block_given?
        content += yield(record)
      else
        content += properties_for(record, :type => 'button') do |p|
          columns = record.class.attr_accessible[:edit].to_a
          record.class.columns.select{|x| columns.include?(x.name) && x.type != :text}.each do |column|
            concat(p.string(column.name)) if column.type == :integer || column.type == :string
          end
        end
      end
      content
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