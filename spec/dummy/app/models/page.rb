class Page < ActiveRecord::Base
	include Amalgam::Types::Page
  include Amalgam::Types::Attachable
  include Amalgam::Types::Taggable
  cattr_accessor :admin_attrs
  attr_accessible :created_at, :as => :admin
  self.admin_attrs = [:slug, :title, :identity,:created_at, :redirect]
  has_many :posts

  taggable

  def template_keys
    keys = []
    keys << self.slug
    keys
  end

  alias_method :old_to_nodes, :to_nodes

  def to_nodes(fields=[])
    hash = old_to_nodes(fields)
    hash['attr']['class'] = "redirect" if self.redirect
    hash
  end
end