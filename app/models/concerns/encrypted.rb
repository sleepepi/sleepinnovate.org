# frozen_string_literal: true

# Extends classes to encrypt attributes.
module Encrypted
  extend ActiveSupport::Concern

  # Allows encrypted attributes to be attached to models using"
  #   `encrypt :attribute`
  module ClassMethods
    def encrypted(*attributes)
      attributes.each do |attribute|
        class_eval <<-RUBY
          belongs_to :#{attribute}_encrypted_field,
                     class_name: "EncryptedField",
                     foreign_key: "#{attribute}_encrypted_field_id",
                     autosave: true

          def #{attribute}=(data)
            #{attribute}_encrypted_field.data = data.to_s.try(:squish)
          end

          def #{attribute}
            #{attribute}_encrypted_field.data
          end

          def #{attribute}_encrypted_field
            super || build_#{attribute}_encrypted_field
          end
        RUBY
      end
    end
  end
end
