class Group < ActiveRecord::Base
  has_and_belongs_to_many :pages
  attr_accessible :name, :page_ids
end
