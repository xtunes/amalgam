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
          attr_accessible :tag_list, :as => Amalgam.admin_access_attr_as
        end

        def taggable_as(*args)
          options = args.extract_options!
          args = [:tags] if args.empty?
          if options[:order]
            acts_as_ordered_taggable_on *args
          else
            acts_as_taggable_on *args
          end
          args.each do |arg|
            attr_accessible "#{arg.to_s.singularize}_list".to_sym, :as => Amalgam.admin_access_attr_as
          end
        end
      end
    end
  end
end