# frozen_string_literal: true

require "test_helper"

# Tests to assure internal pages are accessible for logged in users.
class InternalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unconsented = users(:unconsented)
    @consented = users(:consented)
    @refused = users(:refused)
    @withdrawn = users(:withdrawn)
  end

  test "should get awards for consented user" do
    login(@consented)
    get awards_url
    assert_response :success
  end

  test "should get dashboard for consented user" do
    login(@consented)
    get dashboard_url
    assert_response :success
  end

  test "should get dashboard for refused user" do
    login(@refused)
    get dashboard_url
    assert_response :success
  end

  test "should get dashboard for withdrawn user" do
    login(@withdrawn)
    get dashboard_url
    assert_response :success
  end

  test "should get parking voucher for newly consented user with a completed profile" do
    get clinic_path("sleep")
    login(users(:consented))
    users(:consented).update(
      date_of_birth: "1984-12-31",
      address: "123 Road Way, City, ST 12345",
      sign_in_count: 1
    )
    users(:consented).save_signature!(IO.readlines(File.join("test", "support", "signatures", "data_uri.txt")).first)
    get parking_url
    assert_response :success
  end

  test "should not get parking voucher for a user without a completed profile" do
    get clinic_path("sleep")
    login(users(:consented))
    users(:consented).update(
      sign_in_count: 1
    )
    get parking_url
    assert_redirected_to dashboard_url
  end

  test "should not get parking voucher for a user who has logged in more than once" do
    get clinic_path("sleep")
    login(users(:consented))
    users(:consented).update(
      date_of_birth: "1984-12-31",
      address: "123 Road Way, City, ST 12345",
      sign_in_count: 2
    )
    users(:consented).save_signature!(IO.readlines(File.join("test", "support", "signatures", "data_uri.txt")).first)
    get parking_url
    assert_redirected_to dashboard_url
  end

  test "should get test my brain for consented user" do
    login(@consented)
    get test_my_brain_url
    assert_response :success
  end

  test "should start test my brain for consented user" do
    login(@consented)
    post test_my_brain_start_url
    @consented.reload
    assert_not_nil @consented.brain_started_at
    assert_redirected_to "#{ENV["test_my_brain_url"]}?id=#{@consented.subject_code}#{@consented.current_event_brain_code}"
  end

  test "should start biobank registration for consented user" do
    login(@consented)
    post biobank_start_url
    @consented.reload
    assert_not_nil @consented.biobank_started_at
    assert_redirected_to ENV["biobank_url"]
  end

  test "should complete biobank registration for consented user" do
    login(@consented)
    post biobank_complete_url
    @consented.reload
    assert_not_nil @consented.biobank_completed_at
    assert_redirected_to dashboard_url
  end

  test "should get leave study page for consented user" do
    login(@consented)
    get leave_study_url
    assert_response :success
  end

  test "should withdraw from study for consented user" do
    login(@consented)
    post submit_leave_study_url(withdraw: "WITHDRAW")
    @consented.reload
    assert_equal true, @consented.withdrawn?
    assert_equal "You left the SleepINNOVATE study.", flash[:notice]
    assert_redirected_to dashboard_url
  end

  test "should not withdraw without typing withdraw for consented user" do
    login(@consented)
    post submit_leave_study_url(withdraw: "Nope")
    @consented.reload
    assert_equal true, @consented.consented?
    assert_template "leave_study"
    assert_response :success
  end
end
