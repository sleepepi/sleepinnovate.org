# frozen_string_literal: true

require "test_helper"

# Tests to assure admins can view admin dashboard.
class Admin::AdminControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @regular_user = users(:one)
  end

  test "should get admin dashboard for admin" do
    login(@admin)
    get admin_url
    assert_response :success
  end

  test "should not get admin dashboard for regular user" do
    login(@regular_user)
    get admin_url
    assert_redirected_to dashboard_path
  end

  test "should get admin consent report for admin" do
    login(@admin)
    get admin_consented_url
    assert_response :success
  end

  test "should not get admin consent report for regular user" do
    login(@regular_user)
    get admin_consented_url
    assert_redirected_to dashboard_path
  end

  test "should get admin consent report by clinic for admin" do
    login(@admin)
    get admin_consented_clinic_url("lab-1")
    assert_response :success
  end

  test "should not get admin consent report by clinic for regular user" do
    login(@regular_user)
    get admin_consented_clinic_url("lab-1")
    assert_redirected_to dashboard_path
  end
end
