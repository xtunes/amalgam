class Page < ActiveRecord::Base
	include Amalgam::Models::Page
  has_and_belongs_to_many :groups

	attr_accessible :parent_id ,:prev_id ,:next_id ,:title ,:slug , :body, :group_ids
  # attr_accessible :parent_id, :prev_id ,:next_id ,:title ,:slug , :as => :admin
  # attr_accessible :body, :as => :edit
end
