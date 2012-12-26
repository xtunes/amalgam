module Amalgam
	module Models
		module Page
		  extend ActiveSupport::Concern
		  included do
		    include Amalgam::Models::Hierachical
        include Amalgam::Models::Attachable
        include Amalgam::Models::Templatable
        include Amalgam::Models::Groupable
		  end
		end
	end
end