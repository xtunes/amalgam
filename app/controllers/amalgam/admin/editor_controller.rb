module Amalgam
  class Admin::EditorController < Admin::BaseController

    def update
      ContentPersistence.save(params[:content]) if params[:content]
      respond_to do |format|
        format.json {render :text => '{}'}
        format.js {
          render :text => 'Mercury.trigger("saved")'
        }
      end
    end

    # POST /images.json
    def upload_image
      @image = Attachment.new(params[:image])
      respond_to do |format|
        if @image.save
          format.json { render :json => @image }
        end
      end
    end
  end
end