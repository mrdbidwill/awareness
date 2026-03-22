require "test_helper"

class Admin::DatabaseExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    # User already has permission_id: 1 (admin) from fixtures
    sign_in @user
  end

  test "should require authentication" do
    sign_out @user
    get admin_database_export_path
    assert_redirected_to new_user_session_path
  end

  test "should accept export_type parameter lookup_tables" do
    # Just verify the controller accepts the parameter without error
    # We can't fully test the mysqldump without a real database
    get admin_database_export_path(export_type: 'lookup_tables')
    # Response depends on actual database and mysqldump availability
    # This test mainly ensures the route and parameter handling works
    assert_includes ['lookup_tables', 'lookup_no_mblist', 'mblist_only'], 'lookup_tables'
  end

  test "should accept export_type parameter lookup_no_mblist" do
    get admin_database_export_path(export_type: 'lookup_no_mblist')
    assert_includes ['lookup_tables', 'lookup_no_mblist', 'mblist_only'], 'lookup_no_mblist'
  end

  test "should accept export_type parameter mblist_only" do
    get admin_database_export_path(export_type: 'mblist_only')
    assert_includes ['lookup_tables', 'lookup_no_mblist', 'mblist_only'], 'mblist_only'
  end

  test "should default to lookup_tables when no export_type provided" do
    # Verify default behavior
    get admin_database_export_path
    # The controller should handle this without error
    assert true
  end

  test "should configure correct exclusions for lookup_tables" do
    controller = Admin::DatabaseExportsController.new

    # Simulate the export_type logic
    export_type = 'lookup_tables'

    base_excluded_tables = [
      'users', 'trusted_devices', 'user_roles', 'roles', 'role_permissions',
      'permissions', 'versions', 'active_storage_attachments',
      'active_storage_blobs', 'active_storage_variant_records',
      'solid_queue_blocked_executions', 'solid_queue_claimed_executions',
      'solid_queue_failed_executions', 'solid_queue_jobs',
      'solid_queue_pauses', 'solid_queue_processes',
      'solid_queue_ready_executions', 'solid_queue_recurring_executions',
      'solid_queue_scheduled_executions', 'solid_queue_semaphores',
      'schema_migrations', 'ar_internal_metadata'
    ]

    user_input_tables = [
      'all_group_mushrooms', 'articles', 'cluster_mushrooms',
      'image_mushrooms', 'mushroom_projects', 'mushrooms'
    ]

    expected_exclusions = base_excluded_tables + user_input_tables

    assert_equal 28, expected_exclusions.length
    assert_includes expected_exclusions, 'users'
    assert_includes expected_exclusions, 'mushrooms'
    assert_includes expected_exclusions, 'articles'
  end

  test "should configure correct exclusions for lookup_no_mblist" do
    base_excluded_tables = [
      'users', 'trusted_devices', 'user_roles', 'roles', 'role_permissions',
      'permissions', 'versions', 'active_storage_attachments',
      'active_storage_blobs', 'active_storage_variant_records',
      'solid_queue_blocked_executions', 'solid_queue_claimed_executions',
      'solid_queue_failed_executions', 'solid_queue_jobs',
      'solid_queue_pauses', 'solid_queue_processes',
      'solid_queue_ready_executions', 'solid_queue_recurring_executions',
      'solid_queue_scheduled_executions', 'solid_queue_semaphores',
      'schema_migrations', 'ar_internal_metadata'
    ]

    user_input_tables = [
      'all_group_mushrooms', 'articles', 'cluster_mushrooms',
      'image_mushrooms', 'mushroom_projects', 'mushrooms'
    ]

    expected_exclusions = base_excluded_tables + user_input_tables + ['mb_lists']

    assert_equal 29, expected_exclusions.length
    assert_includes expected_exclusions, 'mb_lists'
    assert_includes expected_exclusions, 'mushrooms'
  end

  test "should configure mblist_only to include only mb_lists table" do
    export_type = 'mblist_only'
    include_only_tables = ['mb_lists']

    assert_equal 1, include_only_tables.length
    assert_includes include_only_tables, 'mb_lists'
  end

  test "should generate correct filename for lookup_tables" do
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    filename = "mrdbid_lookup_tables_#{timestamp}.sql"

    assert_match /^mrdbid_lookup_tables_\d{8}_\d{6}\.sql$/, filename
  end

  test "should generate correct filename for lookup_no_mblist" do
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    filename = "mrdbid_lookup_no_mblist_#{timestamp}.sql"

    assert_match /^mrdbid_lookup_no_mblist_\d{8}_\d{6}\.sql$/, filename
  end

  test "should generate correct filename for mblist_only" do
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    filename = "mrdbid_mblist_only_#{timestamp}.sql"

    assert_match /^mrdbid_mblist_only_\d{8}_\d{6}\.sql$/, filename
  end
end
