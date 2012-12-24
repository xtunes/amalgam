module Amalgam
  module Models
    class BaseGroup < ::ActiveRecord::Base
      set_table_name "base_groups"

      attr_accessible :group_id,:groupable_type,:groupable_id

      belongs_to :group, :class_name => '::Amalgam::Models::Group'
      belongs_to :groupable, :polymorphic => true

      validates_presence_of :group_id
    end
  end
end