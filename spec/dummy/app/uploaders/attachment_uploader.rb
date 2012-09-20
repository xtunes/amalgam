# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  # Create different versions of your uploaded files:
  version :thumb , :if => :image? do
    process :resize_to_fill => [32, 32]
  end

  version :preview , :if => :image? do
    process :resize_to_fill => [186,117]
  end

  # see https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Create-random-and-unique-filenames-for-all-versioned-files
  def filename
     "#{secure_token(5)}.#{file.extension}" if original_filename.present?
  end

  protected
  def secure_token(length = 16)
    model[:secure_token] ||= SecureRandom.hex(length / 2)
  end

  # see https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Do-conditional-processing
  def image?(new_file)
    (new_file.content_type || model.content_type).include? 'image'
  end
end
