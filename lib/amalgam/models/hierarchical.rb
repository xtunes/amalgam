module Amalgam
  module Models
    module Hierachical
      extend ActiveSupport::Concern

      included do
        acts_as_nested_set :dependent => :destroy
        self.reflect_on_association(:children).options[:extend] << ChildrenExtension

        attr_accessor :prev_id,:next_id

        validates :title, :slug, :presence => true
        validates_uniqueness_of :slug, :scope => :parent_id
        validates_with Amalgam::Validator::Slug

        default_scope order('lft ASC')

        before_save :update_hierarchy
        before_save :update_path , :if => :slug_changed?
        after_save :update_descendants_path
      end

      protected
      def update_hierarchy
        old_parent_id = parent_id_changed? ? parent_id_was : parent_id
        # TODO: When hierarchy changed , all field changed state will lost.
        #       So moving or data updating can't be done at same time.
        if prev_id.present?
          self.move_to_right_of(target = Page.find(prev_id))
          @move_to_new_parent_id = false
        elsif next_id.present?
          self.move_to_left_of(target = Page.find(next_id))
          @move_to_new_parent_id = false
        end
        update_path if old_parent_id != parent_id
        true
      end

      def update_path
        @old_path = self.path
        self.path = parent_id.present? ? "#{parent.path}/#{self.slug}" : self.slug
        true
      end

      def update_descendants_path
        if @old_path
          self.class.transaction do
            self.descendants.find_each do |child|
              child.update_attribute(:path, child.path.gsub(/^#{@old_path}/, self.path))
            end
          end
        end
        @old_path = nil
      end
    end

    module ChildrenExtension
      def [](slug)
        return @children_hash[slug] if @children_hash
        @children_hash = HashWithIndifferentAccess.new
        each_with_index do |c,i|
          @children_hash[i] = c
          if c.slug.present?
            @children_hash[c.slug] = c
          end
        end
        @children_hash[slug]
      end
    end
  end
end