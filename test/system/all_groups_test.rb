require "application_system_test_case"

class AllGroupsTest < ApplicationSystemTestCase
  setup do
    @all_group = all_groups(:one)
  end

  test "visiting the index" do
    visit all_groups_url
    assert_selector "h1", text: "All groups"
  end

  test "should create all group" do
    visit all_groups_url
    click_on "New all group"

    fill_in "Comments", with: @all_group.comments
    fill_in "Description", with: @all_group.description
    fill_in "Name", with: @all_group.name
    click_on "Create All group"

    assert_text "All group was successfully created"
    click_on "Back"
  end

  test "should update All group" do
    visit all_group_url(@all_group)
    click_on "Edit this all group", match: :first

    fill_in "Comments", with: @all_group.comments
    fill_in "Description", with: @all_group.description
    fill_in "Name", with: @all_group.name
    click_on "Update All group"

    assert_text "All group was successfully updated"
    click_on "Back"
  end

  test "should destroy All group" do
    visit all_group_url(@all_group)
    accept_confirm { click_on "Delete this all group", match: :first }

    assert_text "All group was successfully deleted"
  end
end
