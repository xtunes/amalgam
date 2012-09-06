module Amalgam
  class Engine < ::Rails::Engine
    isolate_namespace Amalgam

    #http://stackoverflow.com/questions/8797690/rails-3-1-better-way-to-expose-an-engines-helper-within-the-client-app
    initializer 'Amalgam.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Amalgam::Admin::LayoutHelper
      end
    end
  end
end