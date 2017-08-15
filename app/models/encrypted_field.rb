# frozen_string_literal: true

# Stores an encrypted data record.
class EncryptedField < ApplicationRecord
  # Concerns
  include Encryptable

  after_initialize :set_defaults

  # Validations
  validates :encrypted_data, :encrypted_data_iv, presence: true

  # Relationships
  belongs_to :data_encryption_key

  def set_defaults
    self.data = "" if data.nil?
  end

  def data=(plain_data)
    (encrypted, iv) = encrypt(plain_data, encryption_key)
    self[:encrypted_data] = encrypted
    self[:encrypted_data_iv] = iv
  end

  def data
    return nil unless valid?
    decrypt(encrypted_data, encryption_key, encrypted_data_iv)
  end

  def reencrypt!(dek)
    update!(data_encryption_key: dek, data: data)
  end

  private

  def encryption_key
    self.data_encryption_key ||= DataEncryptionKey.primary
    data_encryption_key.key
  end
end
