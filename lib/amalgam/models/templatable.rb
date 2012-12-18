module Amalgam
  module Models
    module Templatable
      extend ActiveSupport::Concern

      def template_keys
        keys = []
        keys << self.slug
        self.groups.each do |g|
          keys << '@' + g.name
        end
        keys
      end
    end
  end
end