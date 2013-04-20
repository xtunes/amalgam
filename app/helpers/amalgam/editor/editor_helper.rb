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
      options[:default_bg_color] ||= '456'
      options[:default_front_color] ||= 'fff'
      options[:default] ||= :dummyimage
      value = fetch_field(obj,field)
      image_url = case options[:default]
      when String
        then options[:default].match(/^(http:\/\/)|^(https:\/\/)/) ? options[:default] : image_path(options[:default])
      when Symbol
        then "http://dummyimage.com/#{options[:thumb].match(/\d*(X|x)\d*/).to_s}/#{options[:default_bg_color]}/#{options[:default_front_color]}.gif"
      end
      options.delete(:default)
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