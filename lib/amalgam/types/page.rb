module Amalgam
  module Types
    module Page
      extend ActiveSupport::Concern
      include Amalgam::Types::Hierachical
      include Amalgam::Types::Seo
      include Amalgam::Types::Contentable

      included do
        attr_accessible :identity, :redirect, :as => Amalgam.admin_access_attr_as
        auto_generate_slug_with :title
        has_content

        validates :title, :presence => true
        validates_uniqueness_of :identity, :allow_nil => true, :allow_blank => true
        validates :identity, :format => { :with => /\A[0-9a-z\-_]+\z/}, :allow_nil => true, :allow_blank => true
      end

      def unique_name
        if identity
          return identity
        else
          return to_param
        end
      end
    end
  end
end