module Amalgam
  module Globalize
    module Helpers
      extend ActiveSupport::Concern
      included do
        before_filter :set_locale
      end

      def set_locale
        extracted_locale = ''
        if can_edit?
          extracted_locale = params[:locale] ||
              session[:locale] ||
              extract_locale_from_subdomain ||
              extract_locale_from_tld
        else
          extracted_locale = params[:locale] ||
              extract_locale_from_subdomain ||
              extract_locale_from_tld
        end

        I18n.locale = (I18n::available_locales.include? extracted_locale.to_sym) ?
            extracted_locale : I18n.default_locale

        session[:locale] = extracted_locale if params[:locale] && can_edit?
      end

      def default_url_options(options={})
        can_edit? ? { :locale => I18n.locale } : {}
      end

      protected

      def extract_locale_from_tld
        res = request.host.split('.').last
        res if res != request.host
      end

      def extract_locale_from_subdomain
        res = request.subdomains.first
        res if !request.subdomains.empty? and res != request.host
      end
    end
  end
end