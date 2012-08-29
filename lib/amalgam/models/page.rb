module Amalgam
	module Models
		module Page
		  extend ActiveSupport::Concern
		  included do
		    include Amalgam::Models::Hierachical
		    store :body
		  end
		end
	end
end