module Amalgam::Globalize
  extend ActiveSupport::Concern
  included do
    include Amalgam::Globalize::Helpers
  end
end