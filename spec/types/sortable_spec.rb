#encoding: UTF-8
require 'spec_helper'

describe Amalgam::Types::Sortable do

  before :all do
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :todos do |t|
        t.integer  :project_id
        t.string   :type
        t.string   :action
        t.integer  :client_priority
        t.integer  :developer_priority
        t.integer  :position
      end

      create_table :users do |t|
        t.string   :type
        t.string   :name
        t.integer  :position
        t.integer  :steves_position
        t.boolean  :topuser
        t.integer  :topuser_position
      end
      create_table :model_checks, :force => true do |t|
        t.string :title
        t.integer :lft
        t.integer :rgt
        t.integer :parent_id
        t.integer :position
        t.integer :project_id
      end
    end
    ActiveRecord::Migration.verbose = true

    class Todo < ActiveRecord::Base
      include Amalgam::Types::Sortable
      attr_accessible :project_id, :type, :action, :client_priority, :developer_priority, :position
      sortable :scope => :project_id, :conditions => 'todos.action IS NOT NULL'
      sortable :scope => :project_id, :column => :client_priority, :list_name => :client
      sortable :scope => :project_id, :column => :developer_priority, :list_name => :developer
    end

    class TodoChild < Todo
    end

    class User < ActiveRecord::Base
      include Amalgam::Types::Sortable
      attr_accessible :name, :type, :steves_position, :topuser, :topuser_position, :position
      sortable :scope => :type
      sortable :conditions => { :name => 'steve' }, :column => :steves_position, :list_name => :steves
      sortable :scope => :topuser, :column => :topuser_position, :list_name => :topusers
    end

    class Admin < User
    end

    class ModelCheck < ActiveRecord::Base
      include Amalgam::Types::Sortable
      attr_accessible :title
      sortable :scope => :project_id
    end
  end

  it "test_should_add_to_lists" do
    @todo = Todo.create
    @todo.client_priority.should eq(1)
    @todo.developer_priority.should eq(1)
  end

  it "test_should_increment_lists" do
    Todo.create
    @todo = Todo.create
    @todo.client_priority.should eq(2)
    @todo.developer_priority.should eq(2)
  end

  it "test_should_scope_lists" do
    Todo.create
    @todo = Todo.create :project_id => 1
    @todo.client_priority.should eq(1)
    @todo.developer_priority.should eq(1)
  end
  it "test_should_remove_from_lists_on_destroy" do
    Todo.create
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo_2.client_priority.should eq(3)
    @todo_2.developer_priority.should eq(3)
    @todo.destroy
    @todo_2.reload
    @todo_2.client_priority.should eq(2)
    @todo_2.developer_priority.should eq(2)
  end

  it "test_should_return_first_item" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo_2.first_item(:client).should eq @todo
    @todo_2.first_item(:developer).should eq @todo
  end

  it "test_should_return_boolean_for_first_item?" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo.first_item?(:client).should eq(true)
    @todo_2.first_item?(:client).should eq(false)
  end

  it "test_should_return_boolean_for_in_list?" do
    @todo = Todo.new
    !@todo.in_list?(:client).should eq(false)
    @todo.save.should eq(true)
    @todo.in_list?(:client).should eq(true)
    @todo.remove_from_list!(:client)
    !@todo.in_list?(:client).should eq(false)
  end

  it "test_should_insert_at!" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo_3 = Todo.create
    @todo.insert_at!(2, :client)
    @todo_2.reload
    @todo_3.reload
    @todo_2.client_priority.should eq 1
    @todo.client_priority.should eq 2
    @todo_3.client_priority.should eq 3
  end


  it "test_item_at_offset_should_return_previous_item" do
    @todo = Todo.create
    @todo_2 = Todo.create :project_id => 1
    @todo_3 = Todo.create
    @todo_3.item_at_offset(-1, :client).should eq @todo
  end

  it "test_item_at_offset_should_return_next_item" do
    @todo = Todo.create
    @todo_2 = Todo.create :project_id => 1
    @todo_3 = Todo.create
    @todo.item_at_offset(1, :client).should eq @todo_3
  end

  it "test_item_at_offset_should_return_nil_for_non_existent_offset" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo.item_at_offset(-1, :client).should eq(nil)
    @todo.item_at_offset(2, :client).should eq(nil)
  end

  it "test_should_return_last_item" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo.last_item(:client).should eq @todo_2
    @todo.last_item(:developer).should eq @todo_2
  end

  it "test_should_return_boolean_for_last_item?" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo_2.last_item?(:client).should eq true
    @todo.last_item?(:client).should eq false
  end

  it "test_should_return_last_position" do
    Todo.new.last_position(:client).should eq 0
    @todo = Todo.create
    @todo.last_position(:client).should eq 1
    Todo.create
    @todo.last_position(:client).should eq 2
  end

  it "test_should_move_down" do
    @todo = Todo.create
    Todo.create
    @todo.client_priority.should eq 1
    @todo.move_down!(:client)
    @todo.client_priority.should eq 2
  end

  it "test_should_move_up" do
    Todo.create
    @todo = Todo.create
    @todo.client_priority.should eq 2
    @todo.move_up!(:client)
    @todo.client_priority.should eq 1
  end

  it "test_should_move_to_bottom" do
    @todo = Todo.create
    Todo.create
    Todo.create
    @todo.client_priority.should eq 1
    @todo.move_to_bottom!(:client)
    @todo.client_priority.should eq 3
  end

  it "test_should_move_to_top" do
    Todo.create
    Todo.create
    @todo = Todo.create
    @todo.client_priority.should eq 3
    @todo.move_to_top!(:client)
    @todo.client_priority.should eq 1
  end

  it "test_should_return_next_item" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo.next_item(:client).should eq @todo_2
    @todo_2.next_item(:client).should eq nil
  end

  it "test_should_return_previous_item" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo_2.previous_item(:client).should eq @todo
    @todo.previous_item(:client).should eq nil
  end

  it "test_should_clear_sortable_scope_changes_when_reloading" do
    @todo = Todo.create
    @todo.project_id = 1
    @todo.sortable_scope_changed?.should eq true
    @todo.reload
    @todo.sortable_scope_changed?.should eq false
  end

  it "test_should_remove_from_list" do
    @todo = Todo.create
    @todo_2 = Todo.create
    @todo.client_priority.should eq 1
    @todo_2.client_priority.should eq 2
    @todo.remove_from_list!(:client)
    @todo_2.reload
    @todo.client_priority.should eq nil
    @todo_2.client_priority.should eq 1
  end

  it "test_should_return_boolean_for_sortable_scope_changed?" do
    @todo = Todo.new
    @todo.sortable_scope_changed?.should eq false
    @todo.project_id = 1
    @todo.sortable_scope_changed?.should eq false
    @todo.save.should eq true
    @todo.reload
    @todo.project_id = 2
    @todo.sortable_scope_changed?.should eq true
  end

  it "test_should_list_attrs_in_sortable_scope_changes" do
    @todo = Todo.new
    @todo.sortable_scope_changes.should eq []
    @todo.project_id = 1
    @todo.sortable_scope_changes.should eq []
    @todo.save.should eq true
    @todo.reload
    @todo.project_id = 2
    @todo.sortable_scope_changes.should eq [:project_id]
  end

  it "test_should_raise_invalid_sortable_list_error_if_list_does_not_exist" do
    @todo = Todo.create
    assert_raises ::Amalgam::Types::Sortable::InvalidSortableList do
      @todo.move_up!(:invalid)
    end
  end

  it "test_should_use_conditions" do
    @todo = Todo.create
    @todo_2 = Todo.create :action => 'test'
    @todo_3 = Todo.create
    @todo_4 = Todo.create :action => 'test again'
    @todo_5 = Todo.create
    @todo_6 = Todo.create
    @todo.position.should eq 1
    @todo_2.position.should eq 1
    @todo_3.position.should eq 2
    @todo_4.position.should eq 2
    @todo_5.position.should eq 3
    @todo_6.position.should eq 3
  end

  it "test_should_scope_with_base_class" do
    @todo = Todo.create :action => 'test'
    @todo_2 = TodoChild.create :action => 'test'
    @todo_3 = Todo.create :action => 'test'
    @todo.position.should eq 1
    @todo_2.position.should eq 2
    @todo_3.position.should eq 3
  end

  it "test_should_not_scope_with_base_class" do
    @user = User.create
    @admin = Admin.create
    @user_2 = User.create
    @admin_2 = Admin.create
    @user.position.should eq 1
    @user_2.position.should eq 2
    @admin.position.should eq 1
    @admin_2.position.should eq 2
  end

  it "test_should_accept_hash_conditions" do
    @user = User.create :name => 'steve'
    @user_2 = User.create :name => 'bob'
    @user_3 = User.create :name => 'steve'
    @user.steves_position.should eq 1
    @user_2.steves_position.should eq 2
    @user_3.steves_position.should eq 2
  end

  it "test_should_return_higher_items" do
    @user = User.create
    @user_2 = User.create
    @user_3 = User.create
    @user_3.higher_items.should eq [@user, @user_2]
  end

  it "test_should_return_lower_items" do
    @user = User.create
    @user_2 = User.create
    @user_3 = User.create
    @user.lower_items.should eq [@user_2, @user_3]
  end

  it "test_should_work_with_boolean_scope" do
    @user = User.create :topuser => false
    @user_2 = User.create :topuser => false
    @user.topuser_position.should eq 1
    @user_2.topuser_position.should eq 2
    @user_2.topuser = true
    @user_2.save
    @user_2.topuser_position.should eq 1
  end

  it "test3" do
    ModelCheck.new.should raise_error
    expect{ ModelCheck.send :include, Amalgam::Types::Hierachical}.to raise_error
  end
end