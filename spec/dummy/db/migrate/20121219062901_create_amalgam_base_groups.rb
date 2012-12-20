class CreateAmalgamBaseGroups < ActiveRecord::Migration
  def change
    create_table :amalgam_base_groups do |t|

      t.integer :group_id
      t.string :groupable_type
      t.integer :groupable_id

      t.timestamps
    end
  end
end
