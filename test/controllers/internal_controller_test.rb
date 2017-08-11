# frozen_string_literal: true

require "test_helper"

# Tests to assure internal pages are accessible for logged in users.
class InternalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:one)
    @withdrawn_user = users(:withdrawn)
  end

  test "should get awards for regular user" do
    login(@regular_user)
    get awards_url
    assert_response :success
  end

  test "should get biobank for regular user" do
    login(@regular_user)
    get biobank_url
    assert_response :success
  end

  test "should get consent signature for regular user" do
    login(@regular_user)
    get consent_signature_url
    assert_response :success
  end

  test "should get dashboard for regular user" do
    login(@regular_user)
    get dashboard_url
    assert_response :success
  end

  test "should get dashboard for withdrawn user" do
    login(@withdrawn_user)
    get dashboard_url
    assert_response :success
  end

  test "should get medical record connect for regular user" do
    login(@regular_user)
    get medical_record_url
    assert_response :success
  end

  test "should get parking voucher for regular user" do
    login(@regular_user)
    get parking_url
    assert_response :success
  end

  test "should update date of birth for regular user" do
    login(@regular_user)
    patch medical_record_connect_url(
      date_of_birth: "12/31/1984"
    )
    @regular_user.reload
    assert_equal "1984-12-31", @regular_user.date_of_birth
    assert_redirected_to dashboard_url
  end

  test "should not update invalid date of birth for regular user" do
    login(@regular_user)
    patch medical_record_connect_url(
      date_of_birth: "2/31/1990"
    )
    @regular_user.reload
    assert_nil @regular_user.date_of_birth
    assert_template "medical_record"
    assert_response :success
  end

  test "should get test my brain for regular user" do
    login(@regular_user)
    get test_my_brain_url
    assert_response :success
  end

  test "should start test my brain for regular user" do
    login(@regular_user)
    post test_my_brain_start_url
    @regular_user.reload
    assert_not_nil @regular_user.brain_started_at
    assert_redirected_to "#{ENV['test_my_brain_url']}?id=#{@regular_user.subject_code}"
  end

  test "should complete test my brain for regular user" do
    login(@regular_user)
    post test_my_brain_complete_url
    @regular_user.reload
    assert_not_nil @regular_user.brain_completed_at
    assert_redirected_to dashboard_url
  end

  test "should start biobank registration for regular user" do
    login(@regular_user)
    post biobank_start_url
    @regular_user.reload
    assert_not_nil @regular_user.biobank_started_at
    assert_redirected_to "https://biobank.partners.org"
  end

  test "should complete biobank registration for regular user" do
    login(@regular_user)
    post biobank_complete_url
    @regular_user.reload
    assert_not_nil @regular_user.biobank_completed_at
    assert_redirected_to dashboard_url
  end
end
