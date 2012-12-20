module Amalgam
  module Models
    class Group < ::ActiveRecord::Base

      attr_accessible :name

      has_many :base_groups, :dependent => :destroy, :class_name => '::Amalgam::Models::BaseGroup'

      validates_presence_of :name
      validates_uniqueness_of :name
      validates_length_of :name, :maximum => 255
    end
  end
end