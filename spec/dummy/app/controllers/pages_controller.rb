class PagesController < ApplicationController
  include Amalgam::TemplateFinder

  def show
    @page = Page.where(:slug => params[:id]).first
    raise ActiveRecord::RecordNotFound , "Couldn't find page with slug=#{params[:id]}" if @page.blank?
    render template_for(@page)
  end
end