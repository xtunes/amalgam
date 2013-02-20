class AdminUser < ActiveRecord::Base
  include Amalgam::Authentication::Models::ActiveRecord
  enable_authentication :authentication_keys => [:username,:email], :email => :email
end