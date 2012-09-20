class Attachment < ActiveRecord::Base
  attr_accessible :attachable_id, :file, :name, :description, :position

  mount_uploader :file , AttachmentUploader
  validates_presence_of :file, :on => :create

  belongs_to :attachable, :polymorphic => true


  delegate :url, :to => :file

  def serializable_hash(options = nil)
    options ||= {}
    options[:methods] ||= []
    options[:methods] << :url
    super(options)
  end

  def move(prev_pos,next_pos)
    self.insert_at(prev_pos) if prev_pos && prev_pos>self.position
    self.insert_at(next_pos) if next_pos && next_pos<self.position
  end


  protected

  before_save :update_file_attributes
  def update_file_attributes
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
      self.original_filename = file.file.original_filename
    end
  end
end
