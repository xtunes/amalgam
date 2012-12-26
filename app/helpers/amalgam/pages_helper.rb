module Amalgam
  module PagesHelper
    def link_to_page(page,options={},&block)
      title = options.delete(:title) || page.title
      url   = options.delete(:url) || page_path(page.path)
      condition = options.delete(:if)
      if condition.nil?
        link_to(title,url,options,&block)
      else
        link_to_if(condition,title,url,options,&block)
      end
    end

    def path_by_slug(page)
      page_path(page.path)
    end

    def locale_url(locale)
      available_locales = I18n::available_locales.collect{|m| m.to_s.downcase}
      domain_list = request.host_with_port.split('.')
      if available_locales.include?(domain_list.first.downcase)
        domain_list[0] = locale
        return "#{request.protocol}#{domain_list.join('.')}#{request.fullpath}"
      end
      path_list = request.fullpath.split('/')
      if path_list.present?
        if available_locales.include?(path_list[1].downcase)
          path_list[1] = locale
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
      if request.fullpath.include?('?')
        return "#{request.protocol}#{request.host_with_port}#{request.fullpath}&locale=#{locale}"
      else
        return "#{request.protocol}#{request.host_with_port}#{request.fullpath}?locale=#{locale}"
      end
    end
  end
end