module Amalgam
  module Types
    module Sortable
      extend ActiveSupport::Concern
      include Amalgam::Types::Base
      class InvalidSortableList < StandardError; end
      class NotWorkWithHierachicalError < StandardError; end

      included do
        cattr_accessor :sortable_lists
        self.sortable_lists ||= {}

        define_attribute_methods

        before_create :add_to_lists
        before_update :update_lists
        after_destroy :remove_from_lists
        alias_method_chain :reload, :sortable

        self.assert_not_work_with_hierachical
      end

      module ClassMethods
        def sortable(options = {})

          options = { :column => :position, :conditions => {}, :list_name => nil, :scope => [] }.merge(options)

          options[:conditions] = options[:conditions].inject(['1 = 1']) do |conditions, (key, value)|
            conditions.first << " AND #{key.is_a?(Symbol) ? "#{table_name}.#{key}" : key} "
            if value.nil?
              conditions.first << 'IS NULL'
            else
              conditions.first << '= ?'
              conditions << value
            end
          end if options[:conditions].is_a?(Hash)
          options[:conditions] = Array(options[:conditions])

          options[:scope] = Array(options[:scope])
          options[:scope].each do |scope|
            options[:conditions].first << " AND (#{table_name}.#{scope} = ?)"
            unless self.instance_methods.include?("#{scope}_with_sortable=".to_sym)
              define_method "#{scope}_with_sortable=" do |value|
                sortable_scope_changes << scope unless sortable_scope_changes.include?(scope) || new_record? || value.to_s == send(scope).to_s || !self.class.sortable_lists.any? { |list_name, configuration| configuration[:scope].include?(scope) }
                send("#{scope}_without_sortable=".to_sym, value)
              end
              alias_method_chain "#{scope}=".to_sym, :sortable
            end
          end

          self.sortable_lists[options.delete(:list_name).to_s] = options
        end

        def assert_not_work_with_hierachical
          raise ::Amalgam::Types::Sortable::NotWorkWithHierachicalError.new("this module can not work with hierachical type") if included_modules.include?(Amalgam::Types::Hierachical)
        end

        # Raises InvalidSortableList if <tt>list_name</tt> is not a valid sortable list
        def assert_sortable_list_exists!(list_name)
          raise ::Amalgam::Types::Sortable::InvalidSortableList.new("sortable list '#{list_name}' does not exist") unless sortable_lists.has_key?(list_name.to_s)
        end
      end

      # Adds the current item to the end of the specified list and saves
      #
      # If the current item is already in the list, it will remove it before adding it
      def add_to_list!(list_name = nil)
        remove_from_list!(list_name) if in_list?(list_name)
        add_to_list(list_name)
        save
      end

      # Returns the first item in a list associated with the current item
      def first_item(list_name = nil)
        options = evaluate_sortable_options(list_name)
        self.class.base_class.send("find_by_#{options[:column]}".to_sym, 1, :conditions => options[:conditions])
      end

      # Returns a boolean after determining if the current item is the first item in the specified list
      def first_item?(list_name = nil)
        self == first_item(list_name)
      end

      # Returns an array of items higher than the current item in the specified list
      def higher_items(list_name = nil)
        options = evaluate_sortable_options(list_name)
        options[:conditions].first << " AND #{self.class.table_name}.#{options[:column]} < ?"
        options[:conditions] << send(options[:column])
        self.class.base_class.find(:all, :conditions => options[:conditions], :order => options[:column])
      end

      # Returns a boolean after determining if the current item is in the specified list
      def in_list?(list_name = nil)
        !new_record? && !send(evaluate_sortable_options(list_name)[:column]).nil?
      end

      # Inserts the current item at a certain <tt>position</tt> in the specified list and saves
      #
      # If the current item is already in the list, it will remove it before adding it
      #
      # Also aliased as <tt>insert_at_position!</tt>
      def insert_at!(position = 1, list_name = nil)
        position = position.to_s.to_i
        if position > 0
          remove_from_list!(list_name)
          if position > last_position(list_name)
            add_to_list!(list_name)
          else
            move_lower_items(:down, position - 1, list_name)
            send("#{evaluate_sortable_options(list_name)[:column]}=".to_sym, position)
            save
          end
        end
      end
      alias_method :insert_at_position!, :insert_at!

      # Returns the item with a <tt>position</tt> at a certain offset to the current item's <tt>position</tt> in the specified list
      #
      # Example
      #
      #   @todo = Todo.create
      #   @todo_2 = Todo.create
      #   @todo.item_at_offset(1) # returns @todo_2
      #
      # Returns nil if an item at the specified offset could not be found
      def item_at_offset(offset, list_name = nil)
        options = evaluate_sortable_options(list_name)
        in_list?(list_name) ? self.class.base_class.send("find_by_#{options[:column]}".to_sym, send(options[:column]) + offset.to_s.to_i, :conditions => options[:conditions]) : nil
      end

      # Returns the last item in a list associated with the current item
      def last_item(list_name = nil)
        options = evaluate_sortable_options(list_name)
        options[:conditions].first << " AND #{self.class.table_name}.#{options[:column]} IS NOT NULL"
        klass, conditions = [self.class.base_class, { :conditions => options[:conditions] }]
        klass.send("find_by_#{options[:column]}".to_sym, klass.maximum(options[:column], conditions), conditions)
      end

      # Returns a boolean after determining if the current item is the last item in the specified list
      def last_item?(list_name = nil)
        self == last_item(list_name)
      end

      # Returns the position of the last item in a specified list
      #
      # Returns 0 if there are no items in the specified list
      def last_position(list_name = nil)
        item = last_item(list_name)
        item.nil? ? 0 : item.send(evaluate_sortable_options(list_name)[:column])
      end

      # Returns an array of items lower than the current item in the specified list
      def lower_items(list_name = nil)
        options = evaluate_sortable_options(list_name)
        options[:conditions].first << " AND #{self.class.table_name}.#{options[:column]} > ?"
        options[:conditions] << send(options[:column])
        self.class.base_class.find(:all, :conditions => options[:conditions], :order => "#{self.class.table_name}.#{options[:column]}")
      end

      # Moves the current item down one position in the specified list and saves
      def move_down!(list_name = nil)
        in_list?(list_name) && (last_item?(list_name) || insert_at!(send(evaluate_sortable_options(list_name)[:column]) + 1, list_name))
      end

      # Moves the current item up one position in the specified list and saves
      def move_up!(list_name = nil)
        in_list?(list_name) && (first_item?(list_name) || insert_at!(send(evaluate_sortable_options(list_name)[:column]) - 1, list_name))
      end

      # Moves the current item down to the bottom of the specified list and saves
      def move_to_bottom!(list_name = nil)
        in_list?(list_name) && (last_item?(list_name) || add_to_list!(list_name))
      end

      # Moves the current item up to the top of the specified list and saves
      def move_to_top!(list_name = nil)
        in_list?(list_name) && (first_item?(list_name) || insert_at!(1, list_name))
      end

      # Returns the next lower item in the specified list
      def next_item(list_name = nil)
        item_at_offset(1, list_name)
      end

      # Returns the previous higher item in the specified list
      def previous_item(list_name = nil)
        item_at_offset(-1, list_name)
      end

      # Clears any <tt>sortable_scope_changes</tt> and reloads normally
      def reload_with_sortable(*args)
        @sortable_scope_changes = nil
        reload_without_sortable(*args)
      end

      # Removes the current item from the specified list and saves
      #
      # This will set the <tt>position</tt> to nil
      def remove_from_list!(list_name = nil)
        if in_list?(list_name)
          remove_from_list(list_name)
          save
        else
          false
        end
      end

      # Returns a boolean after determining if this item has changed any attributes specified in the <tt>:scope</tt> options
      def sortable_scope_changed?
        !sortable_scope_changes.empty?
      end

      # Stores an array of attributes specified as a <tt>:scope</tt> that have been changed
      def sortable_scope_changes
        @sortable_scope_changes ||= []
      end

      protected

      # Adds the current item to the specified list
      def add_to_list(list_name = nil)
        send("#{evaluate_sortable_options(list_name)[:column]}=".to_sym, last_position(list_name) + 1)
      end

      # Adds the current item to all sortable lists
      def add_to_lists
        self.class.sortable_lists.each { |list_name, options| add_to_list(list_name) }
      end

      # Evaluates <tt>:scope</tt> option and appends those constraints to the <tt>:conditions</tt> option
      #
      # Returns the evaluated options
      def evaluate_sortable_options(list_name = nil)
        self.class.assert_sortable_list_exists!(list_name)
        options = self.class.sortable_lists[list_name.to_s].inject({}) { |hash, (key, value)| hash.merge! key => Marshal::load(Marshal.dump(value)) } # deep dup
        options[:scope].each do |scope|
          value = send(scope)
          if value.nil?
            options[:conditions].first.gsub!(/#{scope} \= \?/, "#{scope} IS NULL")
          else
            options[:conditions] << value
          end
        end
        options
      end

      # Moves items with a position lower than a certain <tt>position</tt> by an offset of 1 in the specified
      # <tt>direction</tt> (:up or :down) for the specified list
      def move_lower_items(direction, position, list_name = nil)
        options = evaluate_sortable_options(list_name)
        options[:conditions].first << " AND #{self.class.table_name}.#{options[:column]} > ? AND #{self.class.table_name}.#{options[:column]} IS NOT NULL"
        options[:conditions] << position
        self.class.base_class.update_all "#{options[:column]} = #{options[:column]} #{direction == :up ? '-' : '+'} 1", options[:conditions]
      end

      # Removes the current item from the specified list
      def remove_from_list(list_name = nil)
        options = evaluate_sortable_options(list_name)
        move_lower_items(:up, send(options[:column]), list_name)
        send("#{options[:column]}=".to_sym, nil) unless self.frozen?
      end

      # Removes the current item from all sortable lists
      def remove_from_lists
        self.class.sortable_lists.each { |list_name, options| remove_from_list(list_name) }
      end

      # Removes the current item from its old lists and adds it to new lists if any attributes specified as a <tt>:scope</tt> have been changed
      def update_lists
        if self.sortable_scope_changed?
          new_values = sortable_scope_changes.inject({}) do |hash, scope|
            value = send(scope)
            hash[scope] = value.nil? ? nil : (value.dup rescue value)
            hash
          end
          sortable_scope_changes.each do |scope|
            old_value = respond_to?("#{scope}_was".to_sym) ? send("#{scope}_was".to_sym) : !send(scope) # booleans don't have _was methods in older versions
            send("#{scope}=".to_sym, old_value)
          end
          remove_from_lists
          new_values.each { |scope, value| send("#{scope}=".to_sym, value) }
          add_to_lists
        end
      end
    end
  end
end
