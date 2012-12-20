class Page < ActiveRecord::Base
	include Amalgam::Models::Page

	attr_accessible :parent_id ,:prev_id ,:next_id ,:title ,:slug , :body
  # attr_accessible :parent_id, :prev_id ,:next_id ,:title ,:slug , :as => :admin
  # attr_accessible :body, :as => :edit
end
