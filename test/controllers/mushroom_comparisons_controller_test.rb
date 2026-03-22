require "test_helper"

class MushroomComparisonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @mushroom_one = mushrooms(:one) # Has 12 characters
    @mushroom_two = mushrooms(:two)
    @mushroom_three = mushrooms(:three) # Has only 5 characters
    @comparison = mushroom_comparisons(:completed_high_similarity)
  end

  # === Authentication ===

  test "should require authentication for index" do
    sign_out @user
    get mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    assert_redirected_to new_user_session_path
  end

  test "should require authentication for show" do
    sign_out @user
    get mushroom_comparison_path(@comparison)
    assert_redirected_to new_user_session_path
  end

  test "should require authentication for create" do
    sign_out @user
    post mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    assert_redirected_to new_user_session_path
  end

  # === Index Action ===

  test "should get index with sufficient characters" do
    get mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    assert_response :success
    assert_select 'h1', /Compare:/
  end

  test "should display warning for insufficient characters" do
    get mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_three.id)
    assert_response :success
    assert_match(/needs at least.*characters/, @response.body)
  end

  test "should show comparisons when they exist" do
    # Ensure comparison exists
    @comparison.update!(mushroom: @mushroom_one)

    get mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    assert_response :success
    assert_match(/Comparison Results/, @response.body)
  end

  test "should show start button when no comparisons exist" do
    MushroomComparison.where(mushroom: @mushroom_one).destroy_all

    get mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    assert_response :success
    assert_match(/Start Comparison/, @response.body)
  end

  # === Show Action ===

  test "should get show with valid comparison" do
    get mushroom_comparison_path(@comparison)
    assert_response :success
    assert_select 'h1', /Comparison Details/
  end

  test "should display both mushrooms in comparison" do
    get mushroom_comparison_path(@comparison)
    assert_response :success
    assert_match(@comparison.mushroom.name, @response.body)
    assert_match(@comparison.compared_mushroom.name, @response.body)
  end

  test "should display similarity score" do
    get mushroom_comparison_path(@comparison)
    assert_response :success
    assert_match(/#{@comparison.similarity_score}%/, @response.body)
  end

  # === Create Action ===

  test "should enqueue comparison job on create" do
    assert_enqueued_with(job: CompareMushroomsJob, args: [@mushroom_one.id]) do
      post mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    end
  end

  test "should redirect to index after creating comparison" do
    post mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    assert_redirected_to mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
  end

  test "should set flash notice on successful creation" do
    post mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    assert_not_nil flash[:notice]
    assert_match(/Comparison started/, flash[:notice])
  end

  test "should not create comparison for mushroom with insufficient characters" do
    post mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_three.id)
    assert_redirected_to mushroom_path(@mushroom_three)
    assert_not_nil flash[:alert]
    assert_match(/needs at least.*characters/, flash[:alert])
  end

  test "should not enqueue job for mushroom with insufficient characters" do
    assert_no_enqueued_jobs(only: CompareMushroomsJob) do
      post mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_three.id)
    end
  end

  # === Edge Cases ===

  test "should allow any user to compare any mushroom" do
    # Sign in as different user
    other_user = users(:two)
    sign_in other_user

    # Should be able to view comparisons for mushroom owned by user one
    get mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    assert_response :success
  end

  test "should allow any user to create comparison for any mushroom" do
    # Sign in as different user
    other_user = users(:two)
    sign_in other_user

    # Should be able to trigger comparison for mushroom owned by user one
    assert_enqueued_with(job: CompareMushroomsJob, args: [@mushroom_one.id]) do
      post mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
    end
    assert_redirected_to mushroom_mushroom_comparisons_path(mushroom_id: @mushroom_one.id)
  end
end
