class CreatePages < ActiveRecord::Migration
  def up
    create_table :pages do |t|
      t.string :title
      t.string :slug
      t.string :identity
      t.string :redirect
      t.text :content
      t.integer :lft
      t.integer :rgt
      t.integer :parent_id

      t.timestamps
    end
  end

  def down
    drop_table :pages
  end
end