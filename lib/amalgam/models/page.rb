module Amalgam
	module Models
		module Page
		  extend ActiveSupport::Concern
		  included do
		    include Amalgam::Models::Hierachical
        include Amalgam::Models::Attachable
		  end
		end
	end
end