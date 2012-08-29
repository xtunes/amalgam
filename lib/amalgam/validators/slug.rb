module Amalgam::Validator
	class Slug < ActiveModel::Validator
    def validate(record)
      slug_field = options[:field] || :slug
      unless record.send(slug_field) =~ /\A[0-9a-z\-_]+\z/
        record.errors.add(attribute, :invalid, options)
      end
    end
	end
end