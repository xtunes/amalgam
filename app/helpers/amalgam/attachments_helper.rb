module Amalgam
  module AttachmentsHelper
    def link_to_attachment(attachment,options={},&block)
      options[:if] = true if options[:if].nil?
      return content_tag :div, &block unless attachment
      content = options[:content]
      if attachment.content_type.include?("image")
        content ||= image_tag amalgam.attachment_url(attachment)
      else
        content ||= attachment.original_filename
      end
      link = case options[:url]
             when nil then options[:download] ? amalgam.attachment_download_url(attachment) : amalgam.attachment_url(attachment)
             when Symbol then attachment.send(options[:url])
             when String then options[:url]
             end
      link_to_if options[:if] , content ,link, &block
    end
  end
end
