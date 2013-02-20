module Amalgam
  module Authentication
    module Models
      module ActiveRecord
        extend ActiveSupport::Concern

        included do
          cattr_accessor :authentication_keys
        end

        module ClassMethods
          def enable_authentication(options={})
            options[:authentication_keys] ||= [:username]
            options[:email] ||= :email
            self.authentication_keys = options[:authentication_keys]
            attr_accessible *options[:authentication_keys]

            attr_accessible :password, :password_confirmation, :current_password

            attr_accessor :login, :current_password

            has_secure_password

            validates :username, options[:email], :presence => true, :uniqueness => {:case_sensitive => false}
            validates :username, :format => {:with => /\A\w+\z/, :message => 'only A-Z, a-z, _ allowed'}, :length => {:in => 3..20}
            validates options[:email], :format => {:with => /\A^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i}

            validates_presence_of :current_password, :if => Proc.new {|user| user.require_current_password?}
            validate :check_password, :check_current_password
          end

          def locate(content)
            query = []
            authentication_keys.each do |key|
              query << "#{key.to_s} = :value"
            end
            where([query.join(" OR "),{:value => content}]).first
          end

          def authenticate(conditions, password)
            instance = locate(conditions)
            return false unless instance
            instance.authenticate(password)
          end
        end

        def admin?
          true
        end

        protected

        def require_current_password?
          !new_record? and authentication_keys_changed?
        end

        def authentication_keys_changed?
          self.class.authentication_keys.each do |key|
            return true if send("#{key.to_s}_changed?")
          end
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