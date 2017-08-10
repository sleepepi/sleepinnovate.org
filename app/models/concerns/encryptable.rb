# frozen_string_literal: true

# Encrypts and decrypts data using key/iv pairs.
module Encryptable
  extend ActiveSupport::Concern

  included do
    def self.bytes_to_hex(bytes)
      bytes.unpack("H*")[0]
    end

    def self.hex_to_bytes(hex)
      [hex].pack("H*")
    end
  end

  # Encrypts plain data using a 256-bit key represented as a 64 character
  # hexadecimal string.
  # `key_hex` is converted to 256-bit (32-byte) string for the cipher.
  # The `encrypt` method returns a hex-encoded encrypted data string and a
  # hex-encoded Initialization Vector (`iv`)
  def encrypt(data, key_hex)
    key = hex_to_bytes(key_hex)
    (encrypted_data_bytes, iv_bytes) = encrypt_bytes(data, key)
    encrypted_data_hex = bytes_to_hex(encrypted_data_bytes)
    iv_hex = bytes_to_hex(iv_bytes)
    [encrypted_data_hex, iv_hex]
  end

  # Decrypts hex-encoded encrypted data string using a 256-bit key represented
  # as a 64 character hexadecimal string and a 128-bit iv represented as a 32
  # character hexadecimal string.
  # The `decrypt` returns the decrypted data string.
  def decrypt(encrypted_data_hex, key_hex, iv_hex)
    encrypted_data_bytes = hex_to_bytes(encrypted_data_hex)
    key = hex_to_bytes(key_hex)
    iv = hex_to_bytes(iv_hex)
    decrypt_bytes(encrypted_data_bytes, key, iv)
  end

  private

  def encrypt_bytes(data, key)
    cipher = OpenSSL::Cipher::AES.new(256, :CBC).encrypt
    cipher.key = key
    iv = cipher.random_iv # Also sets the generated IV on the Cipher
    encrypted_data = \
      if data.present?
        cipher.update(data) + cipher.final
      else
        cipher.final
      end
    [encrypted_data, iv]
  end

  def decrypt_bytes(encrypted_data, key, iv)
    decipher = OpenSSL::Cipher::AES.new(256, :CBC).decrypt
    decipher.key = key
    decipher.iv = iv
    decipher.update(encrypted_data) + decipher.final
  end

  def bytes_to_hex(bytes)
    self.class.bytes_to_hex(bytes)
  end

  def hex_to_bytes(hex)
    self.class.hex_to_bytes(hex)
  end
end
