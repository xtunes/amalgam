#encoding: UTF-8
require 'spec_helper'

class SeoPage < ActiveRecord::Base
  include Amalgam::Types::Seo
  auto_generate_slug_with :title
end

class SeoPost < ActiveRecord::Base
  include Amalgam::Types::Seo
  auto_generate_slug_with :another_title, :sync => true
end

describe Amalgam::Types::Seo do

  before :all do
    ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :seo_pages, :force => true do |t|
        t.string :title, :slug
      end

      create_table :seo_posts, :force => true do |t|
        t.string :another_title, :slug
      end
    end
    ActiveRecord::Migration.verbose = true
  end

  before do
    @page = FactoryGirl.create(:seo_page)
    @post = FactoryGirl.create(:seo_post)
  end

  it 'if the slug is nil, then will make title into the slug' do
    @page.slug.should eq 'this-is-a-test'
    @post.slug.should eq 'this-is-a-test'
  end

  it '如果你设置了sync属性为true,在你更新title或者其他的指定字段的时候，slug会自动更新' do
    @post.another_title = 'this is a another test'
    @post.save
    @post.slug.should eq 'this-is-a-another-test'
  end

  it '如果你设置了sync属性为false,在你更新title或者其他的指定字段的时候，slug不会自动更新' do
    @page.title = 'this is a another test'
    @page.save
    @page.slug.should eq 'this-is-a-test'
  end

  it 'slug应该可以被手动更新' do
    @page.slug = 'this-is-test'
    @page.save
    @page.slug.should eq 'this-is-test'
  end

  it 'to_param方法会返回slug' do
    @page.to_param.should == 'this-is-a-test'
  end

  it '非ascii字段应该会被自动转成对应的ascii字符串' do
    @post.another_title = '这是测试'
    @post.save
    @post.slug.should eq 'zhe-shi-ce-shi'
  end
end

