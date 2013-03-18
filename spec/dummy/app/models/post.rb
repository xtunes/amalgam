class Post < ActiveRecord::Base
  include Amalgam::Types::Base
  cattr_accessor :admin_attrs
  self.admin_attrs = [:title, :page_id]
  attr_accessible :title, :page_id, :as => :admin
  attr_accessible :title, :page_id, :as => :edit
  belongs_to :page
end
