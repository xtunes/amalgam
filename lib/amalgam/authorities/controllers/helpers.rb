module Amalgam
  module Authorities
    module Controllers
      module Helpers
        extend ActiveSupport::Concern

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
      end
    end
  end
end