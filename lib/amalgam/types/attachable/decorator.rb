module Amalgam
  module Types
    module Attachable
      module Decorator

        protected

        def amalgam_remove_attr(attrs)
          attrs.delete("attachments_attributes")
          super(attrs)
        end

      end
    end
  end
end