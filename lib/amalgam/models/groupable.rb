# encoding: UTF-8
module Amalgam
  module Models
    module Groupable
      extend ActiveSupport::Concern

      included do

        attr_accessible :group_ids

        has_many :base_groups, :as => :groupable, :dependent => :destroy, :include => :group, :class_name => "::Amalgam::Models::BaseGroup"
        has_many :groups, :through => :base_groups, :class_name => "::Amalgam::Models::Group"
      end
    end
  end
end