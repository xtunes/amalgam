module Amalgam
  module Authorities
    module Controllers
      module Helpers
        extend ActiveSupport::Concern

        included do
          helper_method :resource_name
          helper_method :can_edit?
        end

        def self.amalgam_define_helpers(mapping,options = {}) #:nodoc:

          as = options[:as].to_s if options[:as]

          class_eval <<-METHODS, __FILE__, __LINE__ + 1
            def authenticate_#{mapping}!
              if !current_#{mapping}
                store_location
                redirect_to #{mapping}_signin_url, :alert => I18n.t('amalgam.sessions.fail.need_to_be_#{mapping}')
              end
            end

            def #{mapping}_signed_in?
              !!current_#{mapping}
            end

            def current_#{mapping}
              @current_#{mapping} ||= #{mapping.classify.constantize}.find(session[:#{mapping}_id]) if session[:#{mapping}_id]
            end

          METHODS

          if options[:as] && options[:as].to_s != mapping
            class_eval <<-METHODS, __FILE__, __LINE__ + 1
              def authenticate_#{as}!
                if !current_#{as}
                  store_location
                  redirect_to #{mapping}_signin_url, :alert => I18n.t('amalgam.sessions.fail.need_to_be_#{as}')
                end
              end

              def current_#{as}
                current_#{mapping}
              end

              def #{as}_signed_in?
                !!current_#{as}
              end
            METHODS
          end

          ActiveSupport.on_load(:action_controller) do
            helper_method "current_#{mapping}", "#{mapping}_signed_in?"
            helper_method "current_#{as}", "#{as}_signed_in?" if options[:as] && options[:as].to_s != mapping
          end
        end

        protected

        def after_sign_in_path_for(resource)

        end

        def after_sign_out_path_for(resource)
        end

        def sign_out_and_redirect_to(resource)
        end

        def after_sign_up_path_for(resource)
          main_app.root_path
        end

        def after_update_path_for(resource)
          amalgam.admin_root_path
        end

        def redirect_back_or_default(default)
          if default || session[:return_to]
            redirect_to( session[:return_to] || default )
          else
            redirect_to root_url
          end
          session[:return_to] = nil
        end

        def store_location
          session[:return_to] = request.fullpath
        end

        def build_resource(params, classify = true)
          Amalgam.authorities.each do |auth_name,type|
            if params[auth_name]
              self.resource_name = auth_name
              return auth_name.to_s.classify.constantize.new if classify
            end
          end
        end

        def resource_name
          @resource_name
        end

        def resource_name=(name)
          @resource_name = name
        end

        def can_edit?
          admin_signed_in?
        end
      end
    end
  end
end