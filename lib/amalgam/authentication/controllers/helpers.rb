module Amalgam
  module Authentication
    module Controllers
      module Helpers
        extend ActiveSupport::Concern

        included do
          helper_method :admin?
        end

        def admin?
          current_admin
        end

        def current_admin
          @current_user ||= login_from_session || login_from_cookies unless defined?(@current_user)
          @current_user
        end

        def login_as(user)
          session[:user_id] = user.id
          @current_user = user
        end

        def authentication_return_url
          signin_url
        end

        def logout
          session.delete(:user_id)
          @current_user = nil
          forget_me
        end

        def login_from_session
          if session[:user_id].present?
            begin
              Amalgam.user_model.find session[:user_id]
            rescue
              session[:user_id] = nil
            end
          end
        end

        def login_from_cookies
          if cookies[:remember_token].present?
            if user = Amalgam.user_model.find_by_remember_token(cookies[:remember_token])
              session[:user_id] = user.id
              user
            else
              forget_me
              nil
            end
          end
        end

        def login_from_access_token
          @current_user ||= Amalgam.user_model.find_by_access_token(params[:access_token]) if params[:access_token]
        end

        def redirect_back_or_default(default)
          redirect_to(session[:return_to] || default)
          session[:return_to] = nil
        end

        def redirect_referrer_or_default(default)
          redirect_to(request.referrer || default)
        end

        def forget_me
          cookies.delete(:remember_token)
        end

        def remember_me
          cookies[:remember_token] = {
            :value   => current_user.remember_token,
            :expires => 4.weeks.from_now
          }
        end
      end
    end
  end
end