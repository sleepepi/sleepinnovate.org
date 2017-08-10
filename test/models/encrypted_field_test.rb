# frozen_string_literal: true

require "test_helper"

# Test storage of encrypted data.
class EncryptedFieldTest < ActiveSupport::TestCase
  test "should encrypt data" do
    data = "Encrypt this string"
    encrypted_field = EncryptedField.create(data: data)
    assert_equal data, encrypted_field.data
    assert_not_nil encrypted_field.encrypted_data
    assert_not_nil encrypted_field.encrypted_data_iv
    assert_not_nil encrypted_field.data_encryption_key_id
  end

  test "should encrypt empty data" do
    data = ""
    encrypted_field = EncryptedField.create(data: data)
    assert_equal data, encrypted_field.data
    assert_not_nil encrypted_field.encrypted_data
    assert_not_nil encrypted_field.encrypted_data_iv
    assert_not_nil encrypted_field.data_encryption_key_id
  end

  test "should reencrypt data" do
    data = "Reencrypt me."
    encrypted_field = EncryptedField.create(data: data)
    dek = DataEncryptionKey.generate!
    encrypted_field.reencrypt!(dek)
    assert_equal data, encrypted_field.data
    assert_equal dek, encrypted_field.data_encryption_key
  end
end
