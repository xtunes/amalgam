require "amalgam/engine"

module Amalgam
  def self.setup
    require_all!
    yield self
  end

  mattr_accessor :type_whitelist, :routes, :controllers, :authority_keys, :authorities, :attachment_class_name
  @@parent_controller = "ApplicationController"
  @@type_whitelist = []
  @@routes = []
  @@controllers = []
  @@authority_keys = [:email]
  @@authorities = {}
  @@attachment_class_name = 'Attachment'

  def self.resources(*args,&block)
    self.routes << {:args => args, :block => block}
    self.controllers << args.first.to_s
  end

  def self.authority_model(model,options = {})
    if options[:as].present?
      @@authorities[model] = options[:as]
    else
      @@authorities[model] = :default
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
    require 'amalgam/models/page'
    require 'amalgam/template_finder'
    require 'amalgam/editable'
    require 'amalgam/authorities/controllers/helpers'
    require 'amalgam/authorities/model'
    require 'amalgam/authorities/models/active_record'
  end
end