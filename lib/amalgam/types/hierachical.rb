module Amalgam
  module Types
    module Hierachical
      extend ActiveSupport::Concern
      include Amalgam::Types::Base
      class NotWorkWithSortableError < StandardError; end

      included do

        assert_not_work_with_sortable

        acts_as_nested_set :dependent => :destroy

        attr_accessor :left_id,:right_id
        cattr_accessor :node_name
        @@node_name = 'title'

        default_scope order('lft ASC')

        before_save :update_hierarchy
        before_save :update_path, :if => :seo_slug_changed?
        after_save :update_descendants_path
      end

      module ClassMethods
        def assert_not_work_with_sortable
          raise ::Amalgam::Types::Hierachical::NotWorkWithSortableError.new("this module can not work with sortable type") if included_modules.include?(Amalgam::Types::Sortable)
        end
        def tree_json(fields=[],options={})
          fields = self.admin_attrs if self.respond_to?(:admin_attrs) && fields.empty?
          fields.map!{|x| x.to_sym} << self.node_name.to_sym
          fields.uniq!
          self.includes(:children).roots.collect{|p| p.to_nodes(fields,options)}.to_json
        end
      end

      def to_nodes(fields=[],options={})
        hash = {"metadata" => {},"data" => {}, "attr" => {}}
        hash['attr']['id'] = "unit-#{self.id}"
        hash['attr']['resources'] = self.class.to_s.tableize
        hash['attr']['model'] = self.class.to_s.downcase
        hash['metadata']['id'] = self.id
        hash['attr']['href'] = "/admin/#{self.class.to_s.tableize}/#{self.id}/edit"
        fields.each do |field|
          if Amalgam.i18n && self.translated?(field)
            hash['data'][field.to_s] = self.send(:read_attribute,field,{:locale => options[:locale] || I18n.locale})
          else
            hash['data'][field.to_s] = self.send(field)
          end
        end
        hash["children"] = self.children.map { |c| c.to_nodes(fields,options) } if self.children.present?
        hash
      end

      protected
      def update_hierarchy
        old_parent_id = parent_id_changed? ? parent_id_was : parent_id
        # TODO: When hierarchy changed , all field changed state will lost.
        #       So moving or data updating can't be done at same time.
        if left_id.present?
          self.move_to_right_of(left_id)
          @move_to_new_parent_id = false
        elsif right_id.present?
          self.move_to_left_of(right_id)
          @move_to_new_parent_id = false
        end
        update_path if old_parent_id != parent_id
        true
      end

      def update_path
        if is_a?(Amalgam::Types::Seo) && has_attribute?('path')
          @old_path = self.path
          self.path = parent_id.present? ? "#{parent.path}/#{self.slug}" : self.slug
        end
        true
      end

      def seo_slug_changed?
        is_a?(Amalgam::Types::Seo) && slug_changed?
      end

      def update_descendants_path
        if @old_path && is_a?(Amalgam::Types::Seo) && has_attribute?('path')
          self.class.transaction do
            self.descendants.find_each do |child|
              child.update_attribute(:path, child.path.gsub(/^#{@old_path}/, self.path))
            end
          end
        end
        @old_path = nil
      end
    end
  end
end