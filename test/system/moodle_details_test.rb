require "application_system_test_case"

class MoodleDetailsTest < ApplicationSystemTestCase
  setup do
    @moodle_detail = moodle_details(:one)
  end

  test "visiting the index" do
    visit moodle_details_url
    assert_selector "h1", text: "Moodle Details"
  end

  test "creating a Moodle detail" do
    visit moodle_details_url
    click_on "New Moodle Detail"

    fill_in "Host", with: @moodle_detail.host
    fill_in "Token", with: @moodle_detail.token
    fill_in "User", with: @moodle_detail.user_id
    click_on "Create Moodle detail"

    assert_text "Moodle detail was successfully created"
    click_on "Back"
  end

  test "updating a Moodle detail" do
    visit moodle_details_url
    click_on "Edit", match: :first

    fill_in "Host", with: @moodle_detail.host
    fill_in "Token", with: @moodle_detail.token
    fill_in "User", with: @moodle_detail.user_id
    click_on "Update Moodle detail"

    assert_text "Moodle detail was successfully updated"
    click_on "Back"
  end

  test "destroying a Moodle detail" do
    visit moodle_details_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Moodle detail was successfully destroyed"
  end
end
