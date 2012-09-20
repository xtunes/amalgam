module Amalgam
  module Authorities
    module Model
      module ClassMethods
        # Locate an model given its unique login key.
        #
        # @abstract
        # @param [String] key The unique login key.
        # @return [Model] An instance of the user model class.
        def locate(key)
          raise NotImplementedError
        end

        # Authenticate a user with the given key and password.
        #
        # @param [String] key The unique login key provided for a given user.
        # @param [String] password The presumed password for the user.
        # @return [Model] An instance of the user model class.
        def authenticate(conditions, password)
          instance = locate(conditions)
          return false unless instance
          instance.authenticate(password)
        end
      end

      # Returns self if the provided password is correct, false
      # otherwise.
      #
      # @abstract
      # @param [String] password The password to check.
      # @return [self or false] Self if authenticated, false if not.
      def authenticate(password)
        raise NotImplementedError
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
      end
    end
  end
end