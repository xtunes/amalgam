#encoding: UTF-8
require 'spec_helper'
Amalgam.i18n = false
class PagePage < ActiveRecord::Base
  include Amalgam::Types::Page
end

describe Amalgam::Types::Page do
  before :all do
    ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :page_pages, :force => true do |t|
        t.string :title
        t.string :slug
        t.string :identity
        t.string :redirect
        t.text :content
        t.integer :lft
        t.integer :rgt
        t.integer :parent_id
      end
    end
    ActiveRecord::Migration.verbose = true
  end

  before do
    @page_page = PagePage.create({:title => 'this is a test'}, :as => Amalgam.admin_access_attr_as)
  end

  it "identity应该和slug一起初始化，默认值是slug的值,但是不随着slug的修改而修改" do
    @page_page.identity.should eq('this-is-a-test')
    @page_page.slug = "test2"
    @page_page.save
    @page_page.slug.should eq('test2')
    @page_page.identity.should eq('this-is-a-test')
  end

  it "在没有手动设置identity时候,unique_name应当返回slug" do
    @page_page.unique_name.should eq('this-is-a-test')
  end

  it "在手动设置identity后,unique_name应当返回identity" do
    @page_page.identity = "test_a_is_this"
    @page_page.unique_name.should eq("test_a_is_this")
  end

  it "title字段不能为空" do
    I18n.locale = :en
    a = PagePage.create
    a.errors.messages[:title].should eq(["can't be blank"])
  end
end

