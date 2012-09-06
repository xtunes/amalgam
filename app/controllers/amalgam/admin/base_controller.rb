module Amalgam
  class Admin::BaseController < Amalgam::ApplicationController
    before_filter :authenticate_admin!
    layout 'amalgam/admin/application'
  end
end