class PagesController < ApplicationController
  include Amalgam::Controller::Page

  def show
    render template_for(@page)
  end
end