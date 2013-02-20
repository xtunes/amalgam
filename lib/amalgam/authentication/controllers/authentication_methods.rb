module Amalgam
  module Authentication
    module Controllers
      module AuthenticationMethods
        extend ActiveSupport::Concern

        included do
          helper_method :current_admin, :can_edit?
        end

        protected

        def current_admin
          true
        end

        def authentication_return_url
          main_app.root_url
        end

        def can_edit?
          current_admin
        end
      end
    end
  end
end

ActionController::Base.send :include, Amalgam::Authentication::Controllers::AuthenticationMethods