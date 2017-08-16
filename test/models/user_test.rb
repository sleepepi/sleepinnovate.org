# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be unconsented user" do
    assert_equal true, users(:unconsented).unconsented?
    assert_equal false, users(:unconsented).consented?
    assert_equal false, users(:unconsented).withdrawn?
    assert_equal false, users(:unconsented).refused?
    assert_equal false, users(:unconsented).consent_revoked?
  end

  test "should be consented user" do
    assert_equal false, users(:consented).unconsented?
    assert_equal true, users(:consented).consented?
    assert_equal false, users(:consented).withdrawn?
    assert_equal false, users(:consented).refused?
    assert_equal false, users(:consented).consent_revoked?
  end

  test "should be refused user" do
    assert_equal false, users(:refused).unconsented?
    assert_equal false, users(:refused).consented?
    assert_equal false, users(:refused).withdrawn?
    assert_equal true, users(:refused).refused?
    assert_equal true, users(:refused).consent_revoked?
  end

  test "should be withdrawn user" do
    assert_equal false, users(:withdrawn).unconsented?
    assert_equal false, users(:withdrawn).consented?
    assert_equal true, users(:withdrawn).withdrawn?
    assert_equal false, users(:withdrawn).refused?
    assert_equal true, users(:withdrawn).consent_revoked?
  end
end
