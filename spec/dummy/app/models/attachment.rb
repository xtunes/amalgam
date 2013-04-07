class Attachment < ActiveRecord::Base
  include Amalgam::Types::Attachment
  acts_as_attachment
end
