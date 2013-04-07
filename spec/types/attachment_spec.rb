#encoding: UTF-8
require 'spec_helper'

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
describe Amalgam::Types::Attachment do
  before :all do
    ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :attachments, :force => true do |t|
        t.references :attachable ,:polymorphic => true
        t.string :name                         #名称
        t.string :file                         #文件路径
        t.string :content_type                 #mime type
        t.string :original_filename            #原始文件名
        t.text   :meta                         #文件元信息 作为 hash 储存 可以储存图片,视频大小,和自定义自断等
        t.integer :file_size                   #文件大小(字节)
        t.integer :position
      end
      create_table :attachment_pages, :force => true do |t|
        t.string :title
      end
    end
    ActiveRecord::Migration.verbose = true

    class Attachment < ActiveRecord::Base
      include Amalgam::Types::Attachment
      acts_as_attachment :allow_types => /jpg|txt/
      include Amalgam::Types::Sortable
      sortable :scope => [:attachable_id, :attachable_type]
    end

    class AttachmentPage < ActiveRecord::Base
      include Amalgam::Types::Attachable
      attr_accessible :title
    end
  end

  before do
    @attachment_page = AttachmentPage.create(:title => 'test')
    @attachment_page1 = AttachmentPage.create(:title => 'test')
    @test_attachment = @attachment_page.attachments.new
    @test_attachment1 = @attachment_page.attachments.new
    @test_attachment2 = @attachment_page.attachments.new
    @test_attachment3 = @attachment_page1.attachments.new
    @test_attachment.file = File.open('spec/files/test.txt')
    @test_attachment1.file = File.open('spec/files/test.txt')
    @test_attachment2.file = File.open('spec/files/测试.txt')
    @test_attachment3.file = File.open('spec/files/测试.txt')
    @test_attachment.name = 'test'
    @test_attachment1.name = 'test'
    @test_attachment2.name = 'test'
    @test_attachment3.name = 'test'
    @test_attachment.save!
    @test_attachment1.save!
    @test_attachment2.save!
    @test_attachment3.save!
  end

  it 'attachment content should eq expected value' do
    @test_attachment.file.url.include?('/spec/dummy/attachments/files/').should eq true
    @test_attachment.name.should eq 'test'
    @test_attachment.original_filename.should eq 'test.txt'
    @test_attachment2.original_filename.should eq '测试.txt'
  end

  it 'attachment should be sortable as expected in designated scope' do
    @test_attachment.position.should eq 1
    @test_attachment1.position.should eq 2
    @test_attachment2.position.should eq 3
    @test_attachment3.position.should eq 1
  end

  it "attachment should not accept not allowed file type" do
    @test_attachment4 = @attachment_page1.attachments.new
    @test_attachment4.file = File.open('spec/files/test.pdf')
    expect{ @test_attachment4.save! }.to raise_error
  end
end
