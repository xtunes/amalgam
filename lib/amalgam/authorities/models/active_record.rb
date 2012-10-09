require 'active_record'

module Amalgam
  module Authorities
    module Models
      class ActiveRecord < ::ActiveRecord::Base
        include Amalgam::Authorities::Model

        attr_accessible :password, :password_confirmation, :current_password
        attr_accessor :login, :current_password
        self.abstract_class = true
        has_secure_password

        validates_presence_of :current_password, :if => Proc.new {|user| user.require_current_password?}
        validate :check_password, :check_current_password

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

        protected

        def require_current_password?
          !new_record? and (email_changed? or username_changed?)
        end

        def check_password
          if self.password.present?
            errors.add(:password_confirmation, I18n.t('amalgam.registrations.fail.password_confirmation_not_match')) unless self.password == self.password_confirmation
          end
        end

        def check_current_password
          if require_current_password?
            errors.add(:current_password, I18n.t('amalgam.registrations.fail.current_password_not_match')) unless self.authenticate(self.current_password)
          end
        end
      end
    end
  end
end