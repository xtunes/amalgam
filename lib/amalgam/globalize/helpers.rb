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
              extract_locale_from_subdomain ||
              session[:locale]
        else
          extracted_locale = params[:locale] ||
              extract_locale_from_subdomain
        end

        available_locales = ::I18n::available_locales.collect{|m| m.to_s}

        ::I18n.locale = (available_locales.include? extracted_locale.to_s) ?
            extracted_locale : ::I18n.default_locale

        session[:locale] = extracted_locale if params[:locale] && can_edit?
      end

      def default_url_options(options={})
        return {} if Amalgam.i18n == 'subdomain'
        if Amalgam.i18n == 'param'
          return !options[:locale] ? { :locale => ::I18n.locale.to_s } : {}
        end
        {}
      end

      protected

      def extract_locale_from_subdomain
        res = request.subdomains.first
        res if !request.subdomains.empty? and res != request.host
      end
    end
  end
end