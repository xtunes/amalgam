module Amalgam
  module Types
    module Hierachical
      extend ActiveSupport::Concern
      class NotWorkWithSortableError < StandardError; end

      included do

        assert_not_work_with_sortable

        acts_as_nested_set :dependent => :destroy

        attr_accessible :lft, :rgt, :parent_id, :left_id,:right_id

        attr_accessor :left_id,:right_id

        default_scope order('lft ASC')

        before_save :update_hierarchy
        before_save :update_path, :if => :seo_slug_changed?
        after_save :update_descendants_path
      end

      module ClassMethods
        def assert_not_work_with_sortable
          raise ::Amalgam::Types::Hierachical::NotWorkWithSortableError.new("this module can not work with sortable type") if included_modules.include?(Amalgam::Types::Sortable)
        end
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