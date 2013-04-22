# encoding: UTF-8
module Amalgam
  module Types
    module Base
      extend ActiveSupport::Concern

      module ClassMethods
        def foreign_key
          belongs_to_assocs = self.reflections.select{|name,assoc| assoc.macro == :belongs_to}
          if belongs_to_assocs.present?
            if belongs_to_assocs.values.first.options[:foreign_key]
              return belongs_to_assocs.values.first.options[:foreign_key]
            else
              return "#{belongs_to_assocs.keys.first.to_s}_id".to_sym
            end
          else
            return nil
          end
        end

        def parent_class_name
          belongs_to_assocs = self.reflections.select{|name,assoc| assoc.macro == :belongs_to}
          if belongs_to_assocs.present?
            if belongs_to_assocs.values.first.options[:class_name]
              return belongs_to_assocs.values.first.options[:class_name].to_s
            else
              return self.reflections.keys.first.to_s.classify
            end
          else
            return nil
          end
        end

        def search(content,page = 1)
          list = []
          self.columns.select{|x|x.type == :string || x.type == :text}.each do |column|
            list << "#{column.name} like '%#{content}%'"
          end
          if Amalgam.i18n
            self.translates.each do |translate|
              list << "#{translate} like '%#{content}%'"
            end
            if list.present?
              return self.with_translations(I18n.locale).where(list.join(' or ')).page(page)
            else
              return self.with_translations(I18n.locale).page(page)
            end
          else
            if list.present?
              return self.where(list.join(' or ')).page(page)
            else
              return self.page(page)
            end
          end
        end
      end
    end
  end
end