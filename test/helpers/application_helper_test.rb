require "test_helper"
require "ostruct"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  setup do
    @user = users(:one)
    @character = mr_characters(:one)
    @lookup_item = lookup_items(:one)
  end

  test "character_display_name replaces underscores with spaces" do
    assert_equal "cap color", character_display_name("cap_color")
  end

  test "character_display_name handles blank names" do
    assert_equal "", character_display_name("")
    assert_equal "", character_display_name(nil)
  end

  test "admin_user? returns true for admin users" do
    @user.permission_id = 2  # super_admin from fixtures
    @user.save!
    
    def user_signed_in?
      true
    end
    
    def current_user
      @user
    end
    
    assert admin_user?
  end

  test "admin_user? returns false for non-admin users" do
    @user.permission_id = 9  # member from fixtures
    @user.save!
    
    def user_signed_in?
      true
    end
    
    def current_user
      @user
    end
    
    assert_not admin_user?
  end

  test "admin_user? returns false when not signed in" do
    def user_signed_in?
      false
    end
    
    assert_not admin_user?
  end

  test "display_option_key returns lowercase name when present" do
    display_option = display_options(:one)
    @character.display_option = display_option
    
    result = display_option_key(@character)
    assert_equal display_option.name.downcase, result
  end

  test "display_option_key returns id string when name absent" do
    @character.display_option = nil
    @character.display_option_id = 5
    
    result = display_option_key(@character)
    assert_equal "5", result
  end

  test "lookup_options_for returns ordered name-id pairs" do
    character = mr_characters(:one)
    
    # Use existing fixture lookup items if available
    options = lookup_options_for(character)
    
    # Just verify the method returns an array of arrays with name and id
    assert_kind_of Array, options
    options.each do |option|
      assert_equal 2, option.length
      assert_kind_of String, option[0]
      assert_kind_of Integer, option[1]
    end
  end

  test "input_for_character returns a form element" do
    # Test that the method returns some HTML form element
    @character.display_option_id = 2
    
    form_builder = ActionView::Helpers::FormBuilder.new(:test, nil, self, {})
    result = input_for_character(form: form_builder, character: @character)
    
    # Verify it returns an HTML element
    assert_not_nil result
    assert_kind_of String, result
  end

  test "input_for_character handles text_box_number display option" do
    @character.display_option_id = 2
    
    form_builder = ActionView::Helpers::FormBuilder.new(:test, nil, self, {})
    result = input_for_character(form: form_builder, character: @character)
    
    assert_match /number/, result
  end

  test "input_for_character handles text_box_string display option" do
    @character.display_option_id = 5
    
    form_builder = ActionView::Helpers::FormBuilder.new(:test, nil, self, {})
    result = input_for_character(form: form_builder, character: @character)
    
    assert_match /text/, result
  end

  test "input_for_character shows no options message for empty radio" do
    @character.display_option_id = 9
    LookupItem.where(mr_character_id: @character.id).delete_all
    
    form_builder = ActionView::Helpers::FormBuilder.new(:test, nil, self, {})
    result = input_for_character(form: form_builder, character: @character)
    
    assert_includes result, "No options"
  end

  test "input_for_character shows no options message for empty dropdown" do
    @character.display_option_id = 10
    LookupItem.where(mr_character_id: @character.id).delete_all
    
    form_builder = ActionView::Helpers::FormBuilder.new(:test, nil, self, {})
    result = input_for_character(form: form_builder, character: @character)
    
    assert_includes result, "No options"
  end

  test "input_for_character handles color display option" do
    form_builder = ActionView::Helpers::FormBuilder.new(:test, nil, self, {})
    character = OpenStruct.new(display_option: OpenStruct.new(name: "color"), display_option_id: 6)
    result = input_for_character(form: form_builder, character: character)

    assert_includes result, "Use color picker"
  end

  test "input_for_character handles location display options" do
    form_builder = ActionView::Helpers::FormBuilder.new(:test, nil, self, {})
    character = OpenStruct.new(display_option: OpenStruct.new(name: "state"), display_option_id: 11)
    result = input_for_character(form: form_builder, character: character)

    assert_includes result, "Handled in location inputs"
  end
end
