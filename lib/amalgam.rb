require "amalgam/engine"

module Amalgam
	def self.setup
		require_all!
		yield self
	end

	mattr_accessor :type_whitelist
	@@type_whitelist = []

	protected
	def self.require_all!
		require 'amalgam/validators/slug'
		require 'amalgam/content_persistence'
		require 'amalgam/models/hierarchical'
		require 'amalgam/models/page'
	end
end