module Amalgam
  module Models
    class Image < ::ActiveRecord::Base
      self.table_name = "images"
      attr_accessible :file
      image_accessor :file
      attr_accessor :thumb

      def url
        if(self.thumb)
          file.thumb(self.thumb).url
        else
          file.url
        end
      end

      def serializable_hash(options = nil)
        options ||= {}
        options[:methods] ||= []
        options[:methods] << :url
        super(options)
      end
    end
  end
end