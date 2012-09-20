module Amalgam
  module AttachmentsHelper
    def link_to_attachment(attachment,url=nil,version=nil)
      return unless attachment
      if attachment.content_type.include?("image")
        file = version.present? ? attachment.file.send(version) : attachment.file
        content = image_tag(file)
      else
        content = attachment.original_filename
      end
      link = case url
             when nil then attachment.file.to_s
             when Symbol then attachment.send(url)
             when String then url
             end

      link_to_if link.present? , content ,link
    end
  end
end
