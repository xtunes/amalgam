require "amalgam/engine"

module Amalgam
	def self.setup
		require_all!
		yield self
	end

	mattr_accessor :type_whitelist, :routes, :controllers
	@@type_whitelist = []
	@@routes = []
	@@controllers = []

	def self.resources(*args,&block)
		self.routes << {:args => args}
		self.controllers << args.first.to_s
	end

	protected
	def self.require_all!
		require 'amalgam/validators/slug'
		require 'amalgam/content_persistence'
		require 'amalgam/models/hierarchical'
		require 'amalgam/models/page'
		require 'amalgam/template_finder'
		require 'amalgam/editable'
	end
end