class CreateAttachments < ActiveRecord::Migration
  create_table :attachments do |t|
    t.references :attachable ,:polymorphic => {:default => 'Page'}
    t.string :name
    t.string :file
    t.string :content_type
    t.string :original_filename
    t.string :description
    t.string :secure_token
    t.integer :file_size
    t.integer :position

    t.timestamps
  end
end
