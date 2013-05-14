module Amalgam
  module UrlHelper
    def locale_url(locale)
      available_locales = ::I18n::available_locales.collect{|m| m.to_s}

      path_list = request.fullpath.split('/')
      if path_list.present?
        if available_locales.include?(path_list[2])
          path_list[2] = locale
          return "#{request.protocol}#{request.host_with_port}#{path_list.join('/')}"
        end
      else
        return "#{request.protocol}#{request.host_with_port}/#{locale}"
      end

      if locale_param = request.fullpath.match(/locale=[\w|-]*/)
        url = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
        url[locale_param[0]] = "locale=#{locale}"
        return url
      end

      domain_list = request.host_with_port.split('.')
      if available_locales.include?(domain_list.first.downcase)
        domain_list[0] = locale
        return "#{request.protocol}#{domain_list.join('.')}#{request.fullpath}"
      end

      if request.fullpath.include?('?')
        return "#{request.protocol}#{request.host_with_port}#{request.fullpath}&locale=#{locale}"
      else
        return "#{request.protocol}#{request.host_with_port}#{request.fullpath}?locale=#{locale}"
      end
    end

    def with_subdomain(subdomain)
      subdomain = (subdomain || "")
      subdomain += "." unless subdomain.empty?
      [subdomain, request.domain, request.port_string].join
    end

    def url_for(options = nil)
      if options.kind_of?(Hash) && options.has_key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain))
      end
      super
    end
  end
end