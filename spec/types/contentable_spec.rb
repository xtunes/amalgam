#encoding: UTF-8
require 'spec_helper'

describe Amalgam::Types::Contentable do
  before :all do
    ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

    Amalgam.i18n = false

    class ContentablePage < ActiveRecord::Base
      include Amalgam::Types::Contentable
      has_content :content
      attr_accessible :content
    end

    Amalgam.i18n = true

    class Contentablei18nPage < ActiveRecord::Base
      include Amalgam::Types::Contentable
      has_content
      attr_accessible :content
    end

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :contentable_pages, :force => true do |t|
        t.text :content
      end
      create_table :contentablei18n_pages, :force => true do |t|
      end
      Contentablei18nPage.create_translation_table!({:content => :text},{:migrate_data=> true})
    end
    ActiveRecord::Migration.verbose = true
  end

  before do
    @con_page1 = ContentablePage.create
    @con_page2 = Contentablei18nPage.create
  end

  it "content_fields should eq expected" do
    ContentablePage.content_fields.should eq([:content])
  end

  it "content should be used as a hash" do
    @con_page1.content = {}
    @con_page1.content['test'] = 'test'
    @con_page1.save
    @con_page1.content['test'].should eq('test')
  end

  it "content should support i18n" do
    I18n.locale = I18n.default_locale
    @con_page2.content = {}
    @con_page2.content['test'] = 'test'
    @con_page2.save
    @con_page2.content['test'].should eq('test')
    I18n.locale = :en
    @con_page2.content = {}
    @con_page2.content['test'] = 'en_test'
    @con_page2.save
    @con_page2.content['test'].should eq('en_test')
    I18n.locale = I18n.default_locale
    @con_page2.content['test'].should eq('test')
  end
end


