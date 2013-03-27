class Page < ActiveRecord::Base
	include Amalgam::Types::Page
  include Amalgam::Types::Taggable
  cattr_accessor :admin_attrs
  attr_accessible :created_at, :as => :admin
  self.admin_attrs = [:slug, :title, :identity,:created_at]
  has_many :posts

  taggable
  taggable_as :skills

  def template_keys
    keys = []
    keys << self.slug
    keys
  end
end