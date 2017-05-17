# frozen_string_literal: true

require "test_helper"

# Tests to assure external pages are accessible.
class ExternalControllerTest < ActionDispatch::IntegrationTest
  test "should get landing" do
    get landing_url
    assert_response :success
  end

  test "should get sitemap xml file" do
    get sitemap_xml_url
    assert_response :success
  end

  test "should get version" do
    get version_url
    assert_response :success
  end

  test "should get version as json" do
    get version_url(format: "json")
    version = JSON.parse(response.body)
    assert_equal SleepInnovate::VERSION::STRING, version["version"]["string"]
    assert_equal SleepInnovate::VERSION::MAJOR, version["version"]["major"]
    assert_equal SleepInnovate::VERSION::MINOR, version["version"]["minor"]
    assert_equal SleepInnovate::VERSION::TINY, version["version"]["tiny"]
    if SleepInnovate::VERSION::BUILD.nil?
      assert_nil version["version"]["build"]
    else
      assert_equal SleepInnovate::VERSION::BUILD, version["version"]["build"]
    end
    assert_response :success
  end
end
