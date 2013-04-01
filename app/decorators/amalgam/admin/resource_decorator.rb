module Amalgam
  module Admin
    class ResourceDecorator < ::Draper::Decorator

      delegate_all

      def to_param
        source.id
      end
    end
  end
end