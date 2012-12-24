class CreateBaseGroups < ActiveRecord::Migration
  def change
    create_table :base_groups do |t|

      t.integer :group_id
      t.string :groupable_type
      t.integer :groupable_id

      t.timestamps
    end
  end
end
