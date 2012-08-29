module Amalgam
	class ContentPersistence

	  def self.save(content)
	    records = prepare_records(content)
	    records.each do |key,record|
	      instance = record[:class].constantize.find(record[:id])
	      # merge only changed field of model
	      attrs = instance.attributes.slice(*record[:attributes].keys).deep_merge(record[:attributes])
	      instance.update_attributes(attrs)
	    end
	  end

	  def self.sanitize_content_key(key)
	    if r = %r{\A(?<type>[a-z_]+)/(?<id>[0-9a-z]+)\.(?<field>[0-9a-z_]+(\.[0-9a-z_]+)*)\z}.match(key.chomp.downcase)
	      cls = r[:type].classify
	      raise %{Illegal type "#{cls}"} unless Amalgam.type_whitelist.include?(cls)
	      [cls,r[:id],r[:field]]
	    else
	      raise %{Illegal content key "#{key}"}
	    end
	  end

	  def self.prepare_records(content)
	    records = {}
	    content.each do |content_key,content_value|
	      klass,id,field = sanitize_content_key(content_key)
	      record = records["#{klass}/#{id}"] ||= {
	        :class => klass,
	        :id => id,
	        :attributes => {}
	      }
	      # convert form 'field.sub1.sub2 = value' to '{field:{sub1:{sub2:value}}'
	      attribute = (field.split('.') << content_value['value']).reverse.reduce{|value,key| {key => value} }
	      record[:attributes].deep_merge!(attribute)
	    end
	    records
	  end
	end
end