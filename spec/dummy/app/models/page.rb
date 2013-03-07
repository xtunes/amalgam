class Page < ActiveRecord::Base
	include Amalgam::Types::Page

  def template_keys
    keys = []
    keys << self.slug
    keys
  end
end