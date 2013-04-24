module Amalgam
  module Types
    module Contentable
      extend ActiveSupport::Concern
      include Amalgam::Types::Base

      included do
        cattr_accessor :content_fields
      end

      module ClassMethods
        def has_content(*fields_and_options)
          options = fields_and_options.extract_options!
          fields_and_options = [:content] unless fields_and_options.present?
          self.content_fields = fields_and_options
          if Amalgam.i18n
            translates *fields_and_options
            store *fields_and_options
            translation_class.send :store, *fields_and_options
          else
            store *fields_and_options
          end
        end
      end
    end
  end
end