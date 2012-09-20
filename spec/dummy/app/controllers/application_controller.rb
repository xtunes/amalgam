class ApplicationController < Amalgam::ApplicationController
  protect_from_forgery

  protected

  def can_edit?
    admin_signed_in?
  end
end
