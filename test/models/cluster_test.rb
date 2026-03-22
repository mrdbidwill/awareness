# test/models/cluster_test.rb
require "test_helper"

class ClusterTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @cluster = clusters(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @cluster.valid?
  end

  test "should require name" do
    @cluster.name = nil
    assert_not @cluster.valid?
    assert_includes @cluster.errors[:name], "Name cannot be blank."
  end

  test "should require unique name per user case-insensitively" do
    Cluster.create!(name: "UniqueCluster", user: @user)
    duplicate = Cluster.new(name: "uniquecluster", user: @user)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "should allow same name for different users" do
    user2 = users(:two)
    Cluster.create!(name: "SharedName", user: @user)
    duplicate = Cluster.new(name: "SharedName", user: user2)
    assert duplicate.valid?
  end

  test "name should not exceed 255 characters" do
    @cluster.name = "a" * 256
    assert_not @cluster.valid?
    assert_includes @cluster.errors[:name], "Name must not exceed 255 characters."
  end

  # === Associations ===

  test "should belong to user" do
    assert_respond_to @cluster, :user
    assert_instance_of User, @cluster.user
  end

  test "should require user" do
    @cluster.user = nil
    assert_not @cluster.valid?
    assert_includes @cluster.errors[:user], "must exist"
  end

  test "should have many cluster_mushrooms" do
    assert_respond_to @cluster, :cluster_mushrooms
  end

  test "should have many mushrooms through cluster_mushrooms" do
    assert_respond_to @cluster, :mushrooms
  end

  # === Dependent Associations ===

  test "should have dependent destroy configured for cluster_mushrooms" do
    # Verify dependent: :destroy is configured
    reflection = Cluster.reflect_on_association(:cluster_mushrooms)
    assert_equal :destroy, reflection.options[:dependent], "cluster_mushrooms should have dependent: :destroy"
  end

  # === CRUD Operations ===

  test "should create new cluster" do
    assert_difference "Cluster.count", 1 do
      Cluster.create!(name: "New Cluster", user: @user)
    end
  end

  test "should update cluster attributes" do
    @cluster.update(name: "Updated Cluster")
    assert_equal "Updated Cluster", @cluster.reload.name
  end


  # === Timestamps ===

  test "should have timestamps" do
    assert_not_nil @cluster.created_at
    assert_not_nil @cluster.updated_at
  end

  # === Edge Cases ===

  test "should handle empty name" do
    @cluster.name = ""
    assert_not @cluster.valid?
  end

  test "should accept maximum length name" do
    @cluster.name = "a" * 255
    assert @cluster.valid?
  end
end
