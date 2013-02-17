# encoding: UTF-8
module Amalgam
  module Types
    module Attachment
      extend ActiveSupport::Concern
      include Amalgam::Types::Sortable

      included do
        attr_accessible :name, :file, :content_type, :original_filename, :meta, :file_size
        cattr_accessor :attachment_settings
        @@attachment_settings= {
          :uploader => Amalgam::Uploaders::Attachmentploader,
          :temp_dir => "#{Rails.root}/attachments/files/temp",
          :store_dir => "#{Rails.root}/attachments/files",
          :allow_types => nil
        }
        store :meta
        belongs_to :attachable, :polymorphic => true
        sortable :scope => [:attachable_id, :attachable_type]
      end

      module ClassMethods
        def acts_as_attachment(options = {})
          attachment_settings[:uploader] = options[:uploader] if options[:uploader]
          attachment_settings[:temp_dir] = "#{Rails.root}/#{options[:temp_dir]}" if options[:temp_dir]
          attachment_settings[:store_dir] = "#{Rails.root}/#{options[:store_dir]}" if options[:store_dir]
          attachment_settings[:allow_types] = [options[:allow_types]].flatten if options[:allow_types]

          mount_uploader :file , attachment_settings[:uploader]
          validates_presence_of :file, :on => :create

          before_save :update_file_attributes
        end
      end

      protected
      def update_file_attributes
        if file.present? && file_changed?
          self.content_type = file.file.content_type
          self.file_size = file.file.size
        end
      end
    end
  end
end