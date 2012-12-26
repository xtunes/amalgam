class CreatePages < ActiveRecord::Migration
  def up
    create_table :pages do |t|
      t.string :path
      t.string :slug, :null => false
      t.integer :lft
      t.integer :rgt
      t.integer :parent_id

      t.timestamps
    end
    Page.create_translation_table!({:title => :string, :body => :text},{:migrate_data=> true})
  end

  def down
    drop_table :pages
    Page.drop_translation_table! :migrate_data => true
  end
end