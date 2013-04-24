#encoding: UTF-8
require 'spec_helper'

class TaggablePage < ActiveRecord::Base
  include Amalgam::Types::Taggable
  attr_accessible :tag_list, :skill_list, :test_list, :as => Amalgam.admin_access_attr_as
  taggable
  taggable_as :skills
  taggable_as :tests, :order => true
end

describe Amalgam::Types::Taggable do
  before :all do
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table "taggable_pages", :force => true do |t|
      end

      create_table "taggings", :force => true do |t|
        t.integer  "tag_id"
        t.integer  "taggable_id"
        t.string   "taggable_type"
        t.integer  "tagger_id"
        t.string   "tagger_type"
        t.string   "context",       :limit => 128
        t.datetime "created_at"
      end

      add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
      add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

      create_table "tags", :force => true do |t|
        t.string "name"
      end
    end
    ActiveRecord::Migration.verbose = true
  end

  before do
    @page = TaggablePage.create
  end

  it "default tags should work" do
    @page.tag_list.should eq []
    @page.update_attributes({:tag_list => "a,b,c"}, :as => Amalgam.admin_access_attr_as)
    @page.tag_list.should eq ['a','b','c']
  end

  it "custom skills should work" do
    @page.skill_list.should eq []
    @page.update_attributes({:skill_list => "a,b,c"}, :as => Amalgam.admin_access_attr_as)
    @page.skill_list.should eq ['a','b','c']
  end

  it "config should be right" do
    TaggablePage.tag_types.should eq [:tags,:skills,:tests]
    TaggablePage.preserve_tag_order.should eq true
  end
end
