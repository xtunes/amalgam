module Amalgam
  class Admin::ResourcesController < Admin::BaseController
    include Amalgam::Admin::ResourcesUrlHelper
    include Amalgam::Types::Controllers::Actions
    include Amalgam::Types::Controllers::Filters
  end
end