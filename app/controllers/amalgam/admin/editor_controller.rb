module Amalgam
  class Admin::EditorController < Admin::BaseController
    layout false

    def edit
      lang = params[:requested_uri].split('/').first
      if ::I18n::available_locales.collect{|m| m.to_s}.include?(lang) || params[:locale]
        ::I18n.locale = params[:locale] || lang.to_sym
      else
        ::I18n.locale = I18n.default_locale
      end
      render :text => '', :layout => 'amalgam/admin/editor'
    end

    def update
      ::I18n.locale = params[:locale] if params[:locale]
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