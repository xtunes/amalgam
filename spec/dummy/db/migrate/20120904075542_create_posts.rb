class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.timestamps
    end
    Post.create_translation_table!({:title => :string},{:migrate_data=> true})
  end

  def down
    drop_table :posts
    Post.drop_translation_table! :migrate_data => true
  end
end