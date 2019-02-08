require 'test_helper'

class MoodleDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @moodle_detail = moodle_details(:one)
  end

  test "should get index" do
    get moodle_details_url
    assert_response :success
  end

  test "should get new" do
    get new_moodle_detail_url
    assert_response :success
  end

  test "should create moodle_detail" do
    assert_difference('MoodleDetail.count') do
      post moodle_details_url, params: { moodle_detail: { host: @moodle_detail.host, token: @moodle_detail.token, user_id: @moodle_detail.user_id } }
    end

    assert_redirected_to moodle_detail_url(MoodleDetail.last)
  end

  test "should show moodle_detail" do
    get moodle_detail_url(@moodle_detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_moodle_detail_url(@moodle_detail)
    assert_response :success
  end

  test "should update moodle_detail" do
    patch moodle_detail_url(@moodle_detail), params: { moodle_detail: { host: @moodle_detail.host, token: @moodle_detail.token, user_id: @moodle_detail.user_id } }
    assert_redirected_to moodle_detail_url(@moodle_detail)
  end

  test "should destroy moodle_detail" do
    assert_difference('MoodleDetail.count', -1) do
      delete moodle_detail_url(@moodle_detail)
    end

    assert_redirected_to moodle_details_url
  end
end
