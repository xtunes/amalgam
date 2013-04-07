class CreateAttachments < ActiveRecord::Migration
  create_table :attachments do |t|
    t.references :attachable ,:polymorphic => true
    t.string :name                         #名称
    t.string :file                         #文件路径
    t.string :content_type                 #mime type
    t.string :original_filename            #原始文件名
    t.text   :meta                         #文件元信息 作为 hash 储存 可以储存图片,视频大小,和自定义自断等
    t.integer :file_size                   #文件大小(字节)
    t.integer :position

    t.timestamps
  end
end
