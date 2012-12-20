class CreateAmalgamGroups < ActiveRecord::Migration
  def change
    create_table :amalgam_groups do |t|

      t.string :name

      t.timestamps
    end
  end
end
