require "amalgam/engine"

module Amalgam
  def self.setup
    require_all!
    yield self
    if !Rails.application.config.consider_all_requests_local
      load_templates
    end
  end

  mattr_accessor :accepted_formats
  @@accepted_formats = [".haml", ".erb"]

  mattr_accessor :admin_menus
  @@admin_menus = {}

  mattr_accessor :attachment_class_name
  @@attachment_class_name = "Attachment"

  mattr_accessor :type_whitelist
  @@type_whitelist = []

  mattr_accessor :admin_access_attr_as
  @@admin_access_attr_as = :default

  mattr_accessor :edit_access_attr_as
  @@edit_access_attr_as = @@admin_access_attr_as

  mattr_accessor :controllers
  @@controllers = []

  mattr_accessor :mercury_link_whitelist
  @@mercury_link_whitelist = "^\/$"

  mattr_accessor :user_model

  mattr_accessor :attachment_class_name
  @@attachment_class_name = 'Attachment'

  #params or subdomain or nil
  mattr_reader :i18n
  @@i18n = nil

  mattr_accessor :models_with_templates
  @@models_with_templates = []

  mattr_reader :routes
  @@routes = Proc.new do
    resources :pages, :except => [:show]
  end

  def self.i18n=(type,options={})
    @@i18n = type
    fallback_options = {}
    I18n::available_locales.each do |language|
      locales = I18n::available_locales.clone
      locales.delete(language)
      locales.insert(0,language)
      fallback_options[language] = locales
    end
    ::Globalize.fallbacks= fallback_options
  end

  def self.load_templates
    models_with_templates.each do |model|
      Amalgam::TemplateFinder::Rule.load(Rails.root,model.to_s)
    end
  end

  def self.admin_routes(&block)
    @@routes = Proc.new(&block)
  end

  def self.authority_model(model,options = {})
    if options[:as].present?
      @@authorities[model] = options[:as]
    else
      @@authorities[model] = :default
    end
    if options[:redirect_url].present?
      @@authority_urls[model] = options[:redirect_url]
    else
      @@authority_urls[model] = nil
    end
  end

  protected
  def self.require_all!
    require 'amalgam/types/base'
    require 'amalgam/types/seo'
    require 'amalgam/types/hierachical'
    require 'amalgam/types/contentable'
    require 'amalgam/types/page'
    require 'amalgam/types/sortable'
    require 'amalgam/types/attachment'
    require 'amalgam/types/attachable'
    require 'amalgam/types/controllers/actions'
    require 'amalgam/types/controllers/filters'
    require 'amalgam/types/taggable'
    require 'amalgam/uploaders/attachment_uploader'
    require 'amalgam/validators/slug'
    require 'amalgam/utils/delegate_array'
    require 'amalgam/content_persistence'
    require 'amalgam/models/image'
    require 'amalgam/template_finder'
    require 'amalgam/authentication/controllers/helpers'
    require 'amalgam/authentication/routes'
    require 'amalgam/authentication/controllers/authentication_methods'
    require 'amalgam/authentication/models/active_record'
    require 'amalgam/globalize/helpers'
    require 'amalgam/globalize'
    require 'amalgam/tree/exportable'
    require 'amalgam/tree/importable'
    require 'amalgam/controller/page'
    require 'amalgam/types/attachable/decorator'
    require 'amalgam/types/contentable/decorator'
    require 'amalgam/types/hierachical/decorator'
    require 'amalgam/types/page/decorator'
    require 'amalgam/types/taggable/decorator'
  end
end