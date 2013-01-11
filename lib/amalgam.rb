require "amalgam/engine"

module Amalgam
  def self.setup
    require_all!
    yield self
    if !Rails.application.config.consider_all_requests_local
      load_templates
    end
  end

  mattr_accessor :admin_menus
  @@admin_menus = {}

  mattr_accessor :type_whitelist
  @@type_whitelist = []

  mattr_accessor :controllers
  @@controllers = []

  mattr_accessor :authority_keys
  @@authority_keys = [:username]

  mattr_accessor :authorities
  @@authorities = {}

  mattr_accessor :authority_urls
  @@authority_urls = {}

  mattr_accessor :attachment_class_name
  @@attachment_class_name = 'Attachment'

  #params or subdomain or nil
  mattr_accessor :i18n
  @@i18n = nil

  mattr_accessor :models_with_templates
  @@models_with_templates = []

  mattr_reader :routes
  @@routes = Proc.new do
    resources :pages, :except => [:show]
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
    Amalgam::Authorities::Controllers::Helpers.amalgam_define_helpers(model.to_s,options)
  end

  protected
  def self.require_all!
    require 'page_routes'
    require 'amalgam/validators/slug'
    require 'amalgam/content_persistence'
    require 'amalgam/models/hierarchical'
    require 'amalgam/models/attachable'
    require 'amalgam/models/templatable'
    require 'amalgam/models/group'
    require 'amalgam/models/base_group'
    require 'amalgam/models/groupable'
    require 'amalgam/models/page'
    require 'amalgam/template_finder'
    require 'amalgam/editable'
    require 'amalgam/authorities/controllers/helpers'
    require 'amalgam/authorities/model'
    require 'amalgam/authorities/models/active_record'
    require 'amalgam/globalize/helpers'
    require 'amalgam/globalize'
    require 'amalgam/tree/exportable'
    require 'amalgam/tree/importable'
  end
end