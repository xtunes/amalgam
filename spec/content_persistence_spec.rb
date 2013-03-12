require 'spec_helper'

class TestPage < ActiveRecord::Base
  include Amalgam::Types::Contentable
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  has_content :body

  column :title, :string
  column :body, :string
  column :subtitle, :string
  column :protected_field, :string

  attr_accessible :title,:subtitle, :as => :edit
  attr_accessible :title,:subtitle
end

describe Amalgam::ContentPersistence do
  before :all do
    Amalgam.type_whitelist << 'TestPage'
  end
  before do
    @page = TestPage.new(:title => 'origin_title')
    ::TestPage.stub(:find).with('1').and_return(@page)
    ::TestPage.any_instance.stub(:save).and_return(true)
  end

  it "parses the :content param and write the attributes to models" do
    content = {
      "test_pages/1.body.content"=>{
        "type"=>"editable", "value"=>"testcontent"
      },
      "test_pages/1.title"=>{
        "type"=>"editable", "value"=>"testtitle"
      }
    }
    Amalgam::ContentPersistence.save(content)
    @page.title.should == 'testtitle'
    @page.body.should == {'content' => 'testcontent'}
  end

  it 'should not change the protected field' do
    @page.protected_field = 'shouldnotchanged'
    content = {
      "test_pages/1.protected"=>{
        "type"=>"editable", "value"=>"changeit"
      }
    }
    expect { Amalgam::ContentPersistence.save(content) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
  end

  it 'call #save on each model instance only once' do
    @page.should_receive(:save).once.and_return(true)
    @page2 = TestPage.new
    TestPage.stub(:find).with("2").and_return(@page2)
    content = {
      "test_pages/1.body.content"=>{
        "type"=>"editable", "value"=>"testcontent"
      },
      "test_pages/1.title"=>{
        "type"=>"editable", "value"=>"testtitle"
      },
      "test_pages/2.body.content"=>{
        "type"=>"editable", "value"=>"testcontent"
      },
      "test_pages/2.title"=>{
        "type"=>"editable", "value"=>"testtitle"
      }
    }
    Amalgam::ContentPersistence.save(content)

  end

  it 'raise error when type is not in whitelist' do
    content = {
      "illegal_type/1.somefield"=>{
        "type"=>"editable", "value"=>"changeit"
      }
    }
    expect { Amalgam::ContentPersistence.save(content) }.to raise_error(/Illegal type/)
  end

  it 'raise error when content key is illegal' do
    content = {
      "test_pages/puts(1).somefield"=>{
        "type"=>"editable", "value"=>"changeit"
      }
    }
    expect { Amalgam::ContentPersistence.save(content) }.to raise_error(/Illegal content key/)
  end
end