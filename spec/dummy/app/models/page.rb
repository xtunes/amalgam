class Page < ActiveRecord::Base
	include Amalgam::Types::Page
  include Amalgam::Types::Attachable
  include Amalgam::Types::Taggable
  attr_accessible :created_at, :parent_id, :left_id, :right_id, :content, :slug, :title, :identity, :redirect, :tag_list, :attachments_attributes
  has_many :posts

  translates :title

  has_content

  taggable
end