module Amalgam
  module Types
    module Contentable
      module Decorator

        protected

        def amalgam_remove_attr(attrs)
          source.content_fields.each do |field|
            attrs.delete(field.to_s)
          end
          super(attrs)
        end

      end
    end
  end
end