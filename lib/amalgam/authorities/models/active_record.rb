require 'active_record'

module Amalgam
  module Authorities
    module Models
      class ActiveRecord < ::ActiveRecord::Base
        include Amalgam::Authorities::Model

        attr_accessible :password, :password_confirmation
        attr_accessor :login
        self.abstract_class = true
        has_secure_password


        def admin?
          Amalgam.authorities[self.class.model_name.underscore.to_sym] == :admin
        end

        def self.locate(content)
          query = []
          Amalgam.authority_keys.each do |key|
            query << "#{key.to_s} = :value"
          end
          where([query.join(" OR "),{:value => content}]).first
        end
      end
    end
  end
end