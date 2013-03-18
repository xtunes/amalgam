# encoding: UTF-8
module Amalgam
  module Types
    module Base
      extend ActiveSupport::Concern

      module ClassMethods
        def foregin_key
          if self.reflections.present?
            if self.reflections.first[1].options[:foreign_key]
              return self.reflections.first[1].options[:foreign_key]
            else
              return "#{self.reflections.first[0].to_s}_id".to_sym
            end
          else
            return nil
          end
        end

        def parent_class_name
          if self.reflections.present? && self.reflections.first[1].macro == :belongs_to
            if self.reflections.first[1].options[:class_name]
              return self.reflections.first[1].options[:class_name].to_s
            else
              return self.reflections.first[0].to_s.classify
            end
          else
            return nil
          end
        end
      end
    end
  end
end