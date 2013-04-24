module Amalgam
  module Types
    module Taggable
      extend ActiveSupport::Concern

      module ClassMethods

        def taggable(options={})
          if options[:order]
            acts_as_ordered_taggable
          else
            acts_as_taggable
          end
        end

        def taggable_as(*args)
          options = args.extract_options!
          args = [:tags] if args.empty?
          if options[:order]
            acts_as_ordered_taggable_on *args
          else
            acts_as_taggable_on *args
          end
        end
      end
    end
  end
end