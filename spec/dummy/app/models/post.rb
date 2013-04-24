class Post < ActiveRecord::Base
  include Amalgam::Types::Base
  attr_accessible :title, :page_id
  belongs_to :page
  translates :title
end
