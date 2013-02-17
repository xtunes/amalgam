module Amalgam
  module Utils
    class DelegateArray < ::Array
      def method_missing(*args)
        first.send(*args)
      end
    end
  end
end