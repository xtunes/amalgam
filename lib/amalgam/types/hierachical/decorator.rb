module Amalgam
  module Types
    module Hierachical
      module Decorator

        protected

        def amalgam_remove_attr(attrs)
          attrs.delete("parent_id")
          attrs.delete("left_id")
          attrs.delete("right_id")
          super(attrs)
        end

      end
    end
  end
end