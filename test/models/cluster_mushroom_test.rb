# test/models/cluster_mushroom_test.rb
require "test_helper"

class ClusterMushroomTest < ActiveSupport::TestCase
  def setup
    @mushroom = mushrooms(:one)
    @cluster = clusters(:one)
    @cluster_mushroom = cluster_mushrooms(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @cluster_mushroom.valid?
  end

  test "should require mushroom" do
    cluster_mushroom = ClusterMushroom.new(cluster: @cluster)
    assert_not cluster_mushroom.valid?
    assert_includes cluster_mushroom.errors[:mushroom], "must exist"
  end

  test "should require cluster" do
    cluster_mushroom = ClusterMushroom.new(mushroom: @mushroom)
    assert_not cluster_mushroom.valid?
    assert_includes cluster_mushroom.errors[:cluster], "must exist"
  end

  test "should enforce same user for mushroom and cluster" do
    user2 = users(:two)
    other_cluster = Cluster.create!(name: "Other Cluster", user: user2)
    cluster_mushroom = ClusterMushroom.new(mushroom: @mushroom, cluster: other_cluster)
    assert_not cluster_mushroom.valid?
    assert_includes cluster_mushroom.errors[:cluster], "must belong to the same user as the mushroom"
  end

  test "should enforce unique cluster per mushroom" do
    # Clean up any existing associations from fixtures
    ClusterMushroom.where(mushroom: @mushroom, cluster: @cluster).destroy_all
    # First create the association
    ClusterMushroom.create!(mushroom: @mushroom, cluster: @cluster)
    # Then test duplicate
    duplicate = ClusterMushroom.new(mushroom: @mushroom, cluster: @cluster)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:cluster_id], "is already attached to this mushroom"
  end

  # === Associations ===

  test "should belong to mushroom" do
    assert_respond_to @cluster_mushroom, :mushroom
    assert_instance_of Mushroom, @cluster_mushroom.mushroom
  end

  test "should belong to cluster" do
    assert_respond_to @cluster_mushroom, :cluster
    assert_instance_of Cluster, @cluster_mushroom.cluster
  end

  # === CRUD Operations ===

  test "should create cluster_mushroom" do
    cluster2 = Cluster.create!(name: "Another Cluster", user: @mushroom.user)
    assert_difference "ClusterMushroom.count", 1 do
      ClusterMushroom.create!(mushroom: @mushroom, cluster: cluster2)
    end
  end

  test "should delete cluster_mushroom" do
    assert_difference "ClusterMushroom.count", -1 do
      @cluster_mushroom.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @cluster_mushroom.created_at
    assert_not_nil @cluster_mushroom.updated_at
  end

  # === Business Logic ===

  test "should allow same cluster for different mushrooms" do
    mushroom2 = Mushroom.create!(
      name: "Another Mushroom",
      user: @mushroom.user,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    cluster_mushroom2 = ClusterMushroom.new(mushroom: mushroom2, cluster: @cluster)
    assert cluster_mushroom2.valid?
  end

  test "should allow same mushroom with different clusters" do
    cluster2 = Cluster.create!(name: "Cluster 2", user: @mushroom.user)
    cluster_mushroom2 = ClusterMushroom.new(mushroom: @mushroom, cluster: cluster2)
    assert cluster_mushroom2.valid?
  end
end
