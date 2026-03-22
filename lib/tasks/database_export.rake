namespace :db do
  desc "Export production database excluding security-sensitive tables"
  task export: :environment do
    # Tables to exclude for security reasons
    excluded_tables = [
      'users',
      'trusted_devices',
      'user_roles',
      'roles',
      'role_permissions',
      'permissions',
      'versions',
      'active_storage_attachments',
      'active_storage_blobs',
      'active_storage_variant_records',
      'solid_queue_blocked_executions',
      'solid_queue_claimed_executions',
      'solid_queue_failed_executions',
      'solid_queue_jobs',
      'solid_queue_pauses',
      'solid_queue_processes',
      'solid_queue_ready_executions',
      'solid_queue_recurring_executions',
      'solid_queue_scheduled_executions',
      'solid_queue_semaphores',
      'schema_migrations',
      'ar_internal_metadata'
    ]

    # Database configuration
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    database = config[:database]
    username = config[:username]
    password = config[:password]
    host = config[:host] || 'localhost'

    # Build mysqldump command with excluded tables
    ignore_tables = excluded_tables.map { |table| "--ignore-table=#{database}.#{table}" }.join(' ')

    # Create filename with timestamp
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    filename = "mrdbid_export_#{timestamp}.sql"
    output_path = Rails.root.join('tmp', filename)

    # Build mysqldump command
    password_option = password.present? ? "-p#{password}" : ""
    command = "mysqldump -h #{host} -u #{username} #{password_option} #{ignore_tables} #{database} > #{output_path}"

    puts "Exporting database to: #{output_path}"
    puts "Excluding tables: #{excluded_tables.join(', ')}"
    puts ""

    # Execute mysqldump
    system(command)

    if $?.success?
      puts "✓ Database export completed successfully!"
      puts "File saved to: #{output_path}"

      # Display file size
      file_size = File.size(output_path)
      file_size_mb = (file_size / 1024.0 / 1024.0).round(2)
      puts "File size: #{file_size_mb} MB"
    else
      puts "✗ Database export failed!"
      exit 1
    end
  end
end
