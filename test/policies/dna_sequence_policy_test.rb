require 'test_helper'

class DnaSequencePolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @dna_sequence = DnaSequence.new(mushroom_id: 1, dna_barcode_its: "ATCG")
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, DnaSequence).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, DnaSequence).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, DnaSequence).index?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @dna_sequence).show?
  end

  test "should not authorize regular user to show" do
    assert_not Pundit.policy(@regular_user, @dna_sequence).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, DnaSequence.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, DnaSequence.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, DnaSequence.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, DnaSequence.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @dna_sequence).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @dna_sequence).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @dna_sequence).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @dna_sequence).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @dna_sequence).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @dna_sequence).destroy?
  end
end
