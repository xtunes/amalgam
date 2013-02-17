#encoding: UTF-8
require 'spec_helper'

class TestPage < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  acts_as_nested_set :dependent => :destroy

  has_and_belongs_to_many :test_groups

  store :body

  column :slug, :string
  column :body, :string
  column :parent_id, :integer
  column :lft, :integer
  column :rgt, :integer

  attr_accessible :slug,:body

  def template_keys
    keys = []
    keys << self.slug
    self.test_groups.each do |g|
      keys << '@' + g.name
    end
    keys
  end
end

class TestGroup < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  has_and_belongs_to_many :test_pages

  column :name, :string

  attr_accessible :name
end

describe Amalgam::TemplateFinder::Rule do
  before do
    @rules = Amalgam::TemplateFinder::Rule.load(File.dirname(__FILE__),"test_pages")
    @rule = Amalgam::TemplateFinder::Rule.new(['slug2@group2'])

    @page = TestPage.new(:slug => 'slug2')
    @page_group1 = @page.test_groups.new(:name => 'group1')
    @page_group2 = @page.test_groups.new(:name => 'group2')

    @page1 = TestPage.new(:slug => 'slug3')
    @page_group1 = @page1.test_groups.new(:name => 'group1')
    @page_group2 = @page1.test_groups.new(:name => 'group3')

    @page2 = TestPage.new(:slug => 'slug4')
    @page_group1 = @page2.test_groups.new(:name => 'group1')
    @page_group2 = @page2.test_groups.new(:name => 'group2')

    @page4 = TestPage.new(:slug => 'slug5')

    @page5 = TestPage.new(:slug => 'slug6')

    @page6 = TestPage.new(:slug => 'slug7')

    @page7 = TestPage.new(:slug => 'slug8')
    @page7_group1 = @page7.test_groups.new(:name => 'group1')

    @page8 = TestPage.new(:slug => 'slug9')

    @default = TestPage.new(:slug => 'default')
    @default_l1 = TestPage.new(:slug => 'default_l1')
    @default_l2 = TestPage.new(:slug => 'default_l2')

    @page9 = TestPage.new(:slug => 'slug10')

    @page10 = TestPage.new(:slug => 'slug11')
    @page10_group1 = @page10.test_groups.new(:name => 'group10')

    @page11 = @page6.children.new(:slug => 'slug12')
    @page12 = @page6.children.new(:slug => 'slug13')
  end

  it 'only accept templates' do
    @rules.select{|rule| rule.list == ['test']}.present?().should eq(false)
  end

  it "page with groups should has keys" do
    @page.test_groups.length.should eq(2)
    @page.template_keys.length.should eq(3)
    @page.template_keys.should eq ['slug2','@group1','@group2']
  end

  it "page本身可以唯一定位" do
    Amalgam::TemplateFinder::Rule.look_up([@page,@page1,@page2]).should eq ["slug2@group1"]
    Amalgam::TemplateFinder::Rule.look_up([@page1,@page2]).should eq ["@group1"]
    Amalgam::TemplateFinder::Rule.look_up([@page7]).should eq ["@group1"]
  end

  it "需要祖先节点同时满足的准确定位" do
    Amalgam::TemplateFinder::Rule.look_up([@page1,@page2,@page]).should eq ["slug2", "slug3@group3"]
    Amalgam::TemplateFinder::Rule.look_up([@page2,@page4]).should eq ["slug5", "@group1"]
  end

  it "在没有自身满足条件，但是存在上级节点的级别限定模板的时候（如:level1）" do
    Amalgam::TemplateFinder::Rule.look_up([@page4,@page]).should eq ["@group1", "&1"]
    Amalgam::TemplateFinder::Rule.look_up([@page8,@page2,@page4]).should eq ["@group1", "&1"]
    Amalgam::TemplateFinder::Rule.look_up([@page8,@page4,@page2]).should eq ["@group1", "&2"]
  end

  it "在没有自身满足条件，存在祖先节点下的default文件时" do
    Amalgam::TemplateFinder::Rule.look_up([@page6,@page4,@page5]).should eq ['slug6','default']
  end

  it "在没有条件满足的情况下，去根目录的default文件夹里的层级结果去找" do
    Amalgam::TemplateFinder::Rule.look_up([@page5,@page6]).should eq ["default", "&1"]
    Amalgam::TemplateFinder::Rule.look_up([@default_l2,@default_l1,@default]).should eq ['default','&2']
  end

  it "在有祖先节点满足的时候，使用祖先节点的模板" do
    Amalgam::TemplateFinder::Rule.look_up([@page9,@page10]).should eq ["@group10"]
  end

  it "在没有任何规则满足的情况下，使用根目录的show文件" do
    Amalgam::TemplateFinder::Rule.look_up([@page9]).should eq ["show"]
  end

  it "在存在嵌套slug或者group的情况下，内部slug或者group设定的level模板优先级高于外部" do
    Amalgam::TemplateFinder::Rule.look_up([@page9,@page11,@page6]).should eq ["slug7","slug12","&1"]
  end

  it "如果存在并列的父节点和子节点的level模板，优先使用子节点的模板" do
    Amalgam::TemplateFinder::Rule.look_up([@page9,@page12,@page6]).should eq ["slug13","&1"]
  end
end



