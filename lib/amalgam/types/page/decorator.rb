module Amalgam
  module Types
    module Page
      module Decorator

        protected

        def amalgam_remove_attr(attrs)
          attrs.delete("identity")
          super(attrs)
        end

      end
    end
  end
end