module Amalgam
  module Types
    module Taggable
      module Decorator

        protected

        def amalgam_remove_attr(attrs)
          self.source.class.tag_types.each do |type|
            attrs.delete("#{type.to_s.singularize}_list")
          end
          super(attrs)
        end

      end
    end
  end
end