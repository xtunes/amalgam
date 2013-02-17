module Amalgam
  module Uploaders
    class Attachmentploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick

      storage :file

      # see https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Create-random-and-unique-filenames-for-all-versioned-files
      before :cache, :save_original_filename
      def save_original_filename(file)
        model.original_filename ||= file.original_filename if file.respond_to?(:original_filename)
      end

      # see https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Create-random-and-unique-filenames-for-all-versioned-files
      def filename
         "#{secure_token(5)}.#{file.extension}" if original_filename.present?
      end

      def store_dir
        model.attachment_settings[:store_dir]
      end

      def cache_dir
        model.attachment_settings[:temp_dir]
      end

      def extension_white_list
        model.attachment_settings[:allow_types]
      end

      protected

      def secure_token(length = 16)
        var = :"@#{mounted_as}_secure_token"
        model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
      end
    end
  end
end