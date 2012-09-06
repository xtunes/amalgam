class PagesController < ApplicationController
  include Amalgam::TemplateFinder
  include Amalgam::Editable

  def show
    @page = Page.where(:path => params[:path]).first
    raise ActiveRecord::RecordNotFound , "Couldn't find page with PATH=#{params[:path]}" if @page.blank?
    render :action => template_for(@page.path)
  end
end