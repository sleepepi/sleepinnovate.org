# frozen_string_literal: true

require "test_helper"

# Test generation and maintenance of Data Encryption Keys.
class DataEncryptionKeyTest < ActiveSupport::TestCase
  test "should generate new dek" do
    assert_difference("DataEncryptionKey.count") do
      DataEncryptionKey.generate!
    end
  end

  test "should encrypt key" do
    key = DataEncryptionKey.random_key_hex
    dek = DataEncryptionKey.create(key: key)
    assert_equal key, dek.key
    assert_not_nil dek.encrypted_key
    assert_not_nil dek.encrypted_key_iv
  end

  test "should rotate dek" do
    assert_equal 2, DataEncryptionKey.count
    EncryptedField.create(data: "My secret message.")
    EncryptedField.create(data: "Another message.")
    EncryptedField.create(data: "")
    EncryptedField.create(data: nil)
    assert_equal 4, EncryptedField.count
    DataEncryptionKey.rotate_dek!
    assert_equal 1, DataEncryptionKey.count
  end
end
