require "test_helper"

class Admin::DnaSequencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user

    @mushroom = mushrooms(:one)
    # Create a test DNA sequence with actual valid attributes
    @dna_sequence = DnaSequence.create!(
      mushroom: @mushroom,
      notes: "Test notes",
      dna_barcode_its: "ATCGATCG"
    )
  end

  test "should get index" do
    get admin_dna_sequences_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_dna_sequence_url
    assert_response :success
  end

  test "should create dna_sequence" do
    assert_difference("DnaSequence.count") do
      post admin_dna_sequences_url, params: {
        dna_sequence: {
          mushroom_id: @mushroom.id,
          notes: "New notes",
          dna_barcode_its: "GCTAGCTA"
        }
      }
    end

    assert_redirected_to admin_dna_sequence_url(DnaSequence.last)
  end

  test "should show dna_sequence" do
    get admin_dna_sequence_url(@dna_sequence)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_dna_sequence_url(@dna_sequence)
    assert_response :success
  end

  test "should update dna_sequence" do
    patch admin_dna_sequence_url(@dna_sequence), params: {
      dna_sequence: {
        notes: "Updated notes"
      }
    }

    assert_redirected_to admin_dna_sequence_url(@dna_sequence)
  end

  test "should destroy dna_sequence" do
    assert_difference("DnaSequence.count", -1) do
      delete admin_dna_sequence_url(@dna_sequence)
    end

    assert_redirected_to admin_dna_sequences_url
  end
end
