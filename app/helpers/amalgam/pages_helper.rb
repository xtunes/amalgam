module Amalgam
  module PagesHelper
    def link_to_page(page,options={},&block)
      title = options.delete(:title) || page.title
      url   = options.delete(:url) || page_path(page.slug)
      condition = options.delete(:if)
      if condition.nil?
        link_to(title,url,options,&block)
      else
        link_to_if(condition,title,url,options,&block)
      end
    end
  end
end