require 'test_helper'

class ReportRunsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get report_runs_show_url
    assert_response :success
  end

  test "should get index" do
    get report_runs_index_url
    assert_response :success
  end

end
