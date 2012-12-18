class PagesGroups < ActiveRecord::Migration
  def change
    create_table :groups_pages, :id => false do |t|
      t.column :group_id, :integer
      t.column :page_id, :integer
    end
  end
end
