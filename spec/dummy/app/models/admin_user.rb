class AdminUser < Amalgam::Authorities::Models::ActiveRecord
  attr_accessible :email, :username
end