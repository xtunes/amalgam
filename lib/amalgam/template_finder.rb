module Amalgam
  module TemplateFinder
    @@cache = (Rails.env == 'production')
    mattr_accessor :cache

    def self.included(base)
       class << base
        attr_accessor :slug_template_cache
       end
       base.slug_template_cache = Hash.new
    end
    protected
    def template_for(slug)
      return false if slug.blank?
      #
      # TODO improve cache method
      #
      if slug.is_a?(String)
        slugs = slug.split('/')
      else
        slug,slugs=slug.join('/'),slug
      end
      return self.class.slug_template_cache[slug] if self.class.slug_template_cache[slug] === false || self.class.slug_template_cache[slug].present?
      template = lookup_context.find_all([controller_path,slug].join('/'))
      return set_template(slug,slug) if template.present?

      slugs.pop
      #look for default
      if slugs.present?
        default_path = (slugs+['default']).join('/')
        template = lookup_context.find_all([controller_path,default_path].join('/'))
        return set_template(slug,default_path) if template.present?
      else
        return set_template(slug,false)
      end

      #look for parent
      if TemplateFinder.cache
        self.class.slug_template_cache[slug] = template_for(slugs)
      else
        template_for(slugs)
      end
    end

    def set_template(page_path,template_path)
      self.class.slug_template_cache[page_path] = template_path if TemplateFinder.cache
      template_path
    end
  end
end