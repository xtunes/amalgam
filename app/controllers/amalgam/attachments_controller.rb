module Amalgam
  class AttachmentsController < Amalgam::ApplicationController
    def show
      @attachment = Amalgam.attachment_class_name.safe_constantize.find_by_id(params[:id])
      if @attachment
        url = @attachment.file.url
        params[:download] ||= false
        disposition = 'inline'
        if params[:download]
          disposition = 'attachment'
        end
        if params[:thumb]
          url = @attachment.file.thumb.url
        end
        send_file(url,
            :disposition  =>  disposition,
            :stream    =>  true,
            :buffer_size  =>  4096)
      else
        render 'amalgam/errors/404.html'
      end
    end

    def attributes
      respond_to do |format|
        format.json do
          accessors = Amalgam.attachment_class_name.safe_constantize.attachment_settings[:store_accessors]
          accessors_hash = {}
          accessors.each do |acc|
            accessors_hash[acc] = Amalgam.attachment_class_name.safe_constantize.human_attribute_name(acc)
          end
          render :json => accessors_hash.as_json
        end
      end
    end
  end
end