#encoding: UTF-8
require 'spec_helper'

class HierachicalPage < ActiveRecord::Base
  include Amalgam::Types::Hierachical
  attr_accessible :parent_id, :left_id,:right_id, :as => Amalgam.admin_access_attr_as
  attr_accessible :title, :as => Amalgam.admin_access_attr_as
end

class HierachicalseoPage < ActiveRecord::Base
  include Amalgam::Types::Hierachical
  include Amalgam::Types::Seo
  auto_generate_slug_with :title
  attr_accessible :parent_id, :left_id,:right_id, :as => Amalgam.admin_access_attr_as
  attr_accessible :title, :slug, :as => Amalgam.admin_access_attr_as
end

describe Amalgam::Types::Hierachical do
  before :all do
    ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :hierachical_pages, :force => true do |t|
        t.string :title
        t.integer :lft
        t.integer :rgt
        t.integer :parent_id
        t.integer :depth
      end
      create_table :hierachicalcheck_pages, :force => true do |t|
        t.string :title
        t.integer :lft
        t.integer :rgt
        t.integer :parent_id
      end
      create_table :hierachicalseo_pages, :force => true do |t|
        t.string :title
        t.string :slug
        t.string :path
        t.integer :lft
        t.integer :rgt
        t.integer :parent_id
      end
    end
    ActiveRecord::Migration.verbose = true

    class HierachicalcheckPage < ActiveRecord::Base
      include Amalgam::Types::Sortable
      sortable :scope => :parent_id
    end

  end

  before do
    @page1 = HierachicalPage.create({:title => 'test1'}, :as => Amalgam.admin_access_attr_as)
    @page2 = HierachicalPage.create({:title => 'test2'}, :as => Amalgam.admin_access_attr_as)
    @page3 = HierachicalPage.create({:title => 'test3',:parent_id => @page1.id}, :as => Amalgam.admin_access_attr_as)
    @page1_seo = HierachicalseoPage.create({:title => 'test1'}, :as => Amalgam.admin_access_attr_as)
    @page2_seo = HierachicalseoPage.create({:title => 'test2'}, :as => Amalgam.admin_access_attr_as)
    @page3_seo = HierachicalseoPage.create({:title => 'test3',:parent_id => @page1_seo.id}, :as => Amalgam.admin_access_attr_as)
  end

  it "如果有path字段，path应该将层级串联起来" do
    HierachicalPage.node_name.to_s.should eq('title')
    @page3.parent.id.should eq(@page1.id)
    @page3_seo.path.should eq('test1/test3')
  end

  it "节点可转移到其他节点下面,如果在根节点depth为空" do
    @page2.depth.should eq nil
    @page2.update_attributes({:parent_id => @page1.id}, :as => Amalgam.admin_access_attr_as)
    @page2.parent.id.should eq(@page1.id)
    @page2.depth.should eq 1
  end

  it "节点可转移到其他节点左面" do
    @page2.update_attributes({:left_id => @page1.id}, :as => Amalgam.admin_access_attr_as)
    @page2.left_sibling.id.should eq(@page1.id)
  end

  it "节点可转移到其他节点右面" do
    @page2.update_attributes({:right_id => @page1.id},:as => Amalgam.admin_access_attr_as)
    @page2.right_sibling.id.should eq(@page1.id)
  end

  it "节点可转移到其他节点下面时，如果有Path字段，该字段应该自动更新" do
    @page2_seo.update_attributes({:parent_id => @page1_seo.id},:as => Amalgam.admin_access_attr_as)
    @page2_seo.path.should eq('test1/test2')
  end

  it "在更新节点的slug时候，path等相关字段应该跟着更新" do
    @page2_seo.update_attributes({:slug => 'test2_1'}, :as => Amalgam.admin_access_attr_as)
    @page2_seo.path.should eq('test2_1')
  end

  it "该module不能和Hierachical共存" do
    expect { HierachicalcheckPage.send :include, Amalgam::Types::Hierachical }.to raise_error
  end
end