module Amalgam
  module Types
    module Seo
      extend ActiveSupport::Concern
      include Amalgam::Types::Base

      included do
        cattr_accessor :slug_field, :source_field
      end

      module ClassMethods
        def auto_generate_slug_with(field=:title,options={})
          self.node_name = field if self.included_modules.include?(Amalgam::Types::Hierachical)
          options[:slug_field] ||= :slug
          self.slug_field = options[:slug_field]
          self.source_field = field
          if options[:sync]
            before_validation :ensure_unique_url
          else
            before_validation :ensure_unique_url, :on => :create
          end

          validates options[:slug_field], :presence => true
          validates_uniqueness_of options[:slug_field]
          validates options[:slug_field], :format => { :with => /\A[0-9a-z\-_]+\z/}
        end
      end

      def ensure_unique_url
        root = self.send(self.class.source_field).to_s
        self.send("#{self.class.slug_field}=",root.to_url) unless self.new_record? && self.send("#{self.class.slug_field}").present?
      end

      def to_param
        self.send(self.class.slug_field)
      end
    end
  end
end