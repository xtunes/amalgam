module Amalgam
  module Admin
    class ResourcesDecorator < ::Draper::CollectionDecorator
      delegate :current_page, :total_pages, :limit_value
    end
  end
end