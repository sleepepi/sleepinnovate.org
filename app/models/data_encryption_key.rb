# frozen_string_literal: true

# Stores an encrypted data encryption key.
class DataEncryptionKey < ApplicationRecord
  # Concerns
  include Encryptable

  attr_accessor :new_kek

  # Scopes
  scope :unused, -> { where(primary: false).left_outer_joins(:encrypted_fields).having("COUNT(encrypted_fields) = 0").group(:id) }

  # Validations
  validates :encrypted_key, :encrypted_key_iv, presence: true

  # Relationships
  has_many :encrypted_fields

  # Methods
  def self.primary
    where(primary: true).first_or_create(key: random_key_hex)
  end

  def self.generate!(attrs = {})
    create!(attrs.merge(key: random_key_hex))
  end

  def self.random_key_hex(length: 256)
    bytes_to_hex(random_key_bytes(length: length))
  end

  def self.random_key_bytes(length: 256)
    OpenSSL::Random.random_bytes(length / 8)
  end

  def self.rotate_dek!
    dek = generate!
    dek.promote!
    EncryptedField.find_each do |field|
      field.reencrypt!(dek)
    end
    unused.destroy_all
  end

  def promote!
    transaction do
      DataEncryptionKey.where(primary: true).update_all(primary: false)
      update!(primary: true)
    end
  end

  def key=(plain_key)
    (encrypted, iv) = encrypt(plain_key, key_encryption_key)
    self[:encrypted_key] = encrypted
    self[:encrypted_key_iv] = iv
  end

  def key
    decrypt(encrypted_key, key_encryption_key, encrypted_key_iv)
  end

  def reencrypt!(kek)
    update!(new_kek: kek, key: key)
  end

  private

  def key_encryption_key
    new_kek || ENV["key_encryption_key"]
  end
end
