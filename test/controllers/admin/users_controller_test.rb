# frozen_string_literal: true

require "test_helper"

# Tests to assure admins can view and modify user accounts.
class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @regular_user = users(:one)
    @user = users(:one)
    @withdrawn = users(:withdrawn)
  end

  def user_params
    {
      full_name: "Full Name",
      email: "full_name@example.com"
    }
  end

  test "should get index for admin" do
    login(@admin)
    get admin_users_url
    assert_response :success
  end

  test "should not get index for regular user" do
    login(@regular_user)
    get admin_users_url
    assert_redirected_to dashboard_path
  end

  test "should show user for admin" do
    login(@admin)
    get admin_user_url(@user)
    assert_response :success
  end

  test "should get edit for admin" do
    login(@admin)
    get edit_admin_user_url(@user)
    assert_response :success
  end

  test "should update user for admin" do
    login(@admin)
    patch admin_user_url(@user), params: { user: user_params }
    assert_redirected_to admin_user_url(@user)
  end

  test "should unrevoke user for admin" do
    login(@admin)
    post unrevoke_admin_user_url(@withdrawn)
    @withdrawn.reload
    assert_equal false, @withdrawn.consent_revoked?
    assert_redirected_to admin_user_url(@withdrawn)
  end

  test "should destroy user for admin" do
    login(@admin)
    assert_difference("User.current.count", -1) do
      delete admin_user_url(@user)
    end
    assert_redirected_to admin_users_url
  end
end
