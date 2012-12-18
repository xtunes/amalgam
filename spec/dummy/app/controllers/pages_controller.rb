class PagesController < ApplicationController
  include Amalgam::TemplateFinder
  include Amalgam::Editable

  def show
    @page = Page.where(:slug => params[:slug]).first
    raise ActiveRecord::RecordNotFound , "Couldn't find page with PATH=#{params[:slug]}" if @page.blank?
    render template_for(@page)
  end
end