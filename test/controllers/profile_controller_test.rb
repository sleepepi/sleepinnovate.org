# frozen_string_literal: true

require "test_helper"

# Tests to assure profile pages are accessible for logged in users.
class ProfileControllerTest < ActionDispatch::IntegrationTest
  setup do
    @consented = users(:consented)
  end

  test "should get profile and redirect to settings" do
    login(@consented)
    get profile_url
    assert_redirected_to settings_url
  end

  test "should get complete your profile for consented user" do
    login(@consented)
    get profile_complete_url
    assert_response :success
  end

  test "should complete profile for consented user" do
    login(@consented)
    patch profile_complete_submit_url(
      date_of_birth: { month: "12", day: "31", year: "1984" },
      address: "123 Road Way"
    )
    @consented.reload
    assert_equal "1984-12-31", @consented.date_of_birth
    assert_equal "123 Road Way", @consented.address
    assert_redirected_to profile_signature_url
  end

  test "should not complete profile with invalid date of birth for consented user" do
    login(@consented)
    patch profile_complete_submit_url(
      date_of_birth: { month: "2", day: "31", year: "1984" },
      address: "123 Road Way"
    )
    @consented.reload
    assert_equal "", @consented.date_of_birth
    assert_template "complete"
    assert_response :success
  end

  test "should not complete profile with blank address for consented user" do
    login(@consented)
    patch profile_complete_submit_url(
      date_of_birth: { month: "12", day: "31", year: "1984" },
      address: ""
    )
    @consented.reload
    assert_equal "", @consented.address
    assert_template "complete"
    assert_response :success
  end

  test "should get profile signature for consented user" do
    login(@consented)
    get profile_signature_url
    assert_response :success
  end

  test "should submit signature for consented user" do
    login(@consented)
    patch profile_signature_submit_url(
      data_uri: IO.readlines(File.join("test", "support", "signatures", "data_uri.txt")).first
    )
    @consented.reload
    assert_equal true, @consented.signature.present?
    assert_equal "Welcome to the study! Check your email to complete registration.", flash[:notice]
    assert_redirected_to dashboard_url
  end

  test "should not save blank signature for consented user" do
    login(@consented)
    patch profile_signature_submit_url(
      data_uri: ""
    )
    @consented.reload
    assert_equal false, @consented.signature.present?
    assert_template "signature"
    assert_response :success
  end

  test "should get address for consented user" do
    login(@consented)
    get profile_address_url
    assert_response :success
  end

  test "should get date of birth for consented user" do
    login(@consented)
    get profile_dob_url
    assert_response :success
  end

  test "should update address for consented user" do
    login(@consented)
    patch profile_address_url, params: { address: "123 Road Way, City, ST 12345" }
    @consented.reload
    assert_equal "123 Road Way, City, ST 12345", @consented.address
    assert_redirected_to settings_url
  end

  test "should not update address with blank address for consented user" do
    login(@consented)
    patch profile_address_url, params: { address: "" }
    assert_template "address"
    assert_response :success
  end

  test "should update date of birth for consented user" do
    login(@consented)
    patch profile_dob_url, params: {
      date_of_birth: { month: "12", day: "31", year: "1984" }
    }
    @consented.reload
    assert_equal "1984-12-31", @consented.date_of_birth
    assert_redirected_to settings_url
  end

  test "should not update date of birth with invalid date for consented user" do
    login(@consented)
    patch profile_dob_url, params: {
      date_of_birth: { month: "2", day: "31", year: "1984" }
    }
    assert_template "dob"
    assert_response :success
  end
end
