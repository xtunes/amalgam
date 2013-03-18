class Page < ActiveRecord::Base
	include Amalgam::Types::Page
  cattr_accessor :admin_attrs
  attr_accessible :created_at, :as => :admin
  self.admin_attrs = [:slug, :title, :identity,:created_at]
  has_many :posts
  def template_keys
    keys = []
    keys << self.slug
    keys
  end
end