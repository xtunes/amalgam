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
      @image = params[:image_id] ? Amalgam::Models::Image.find(params[:image_id]) : Amalgam::Models::Image.new(params[:image])
      @image.thumb = params[:thumb]
      respond_to do |format|
        if save_image(params[:image_id],params[:image])
          format.json { render :json => @image }
        end
      end
    end

    protected
    def save_image(uid,params)
      if uid
        return @image.update_attributes(params)
      else
        return @image.save
      end
    end
  end
end