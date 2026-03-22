# MRDBID Backup Strategy

## Overview

This application has a three-tier backup strategy for user data, particularly user-uploaded mushroom images stored in the `storage/` directory.

## Tier 1: Server-Level Backups

**Provider**: Hostinger automated backups
**Coverage**: Entire application including database and `storage/` directory
**Frequency**: According to Hostinger backup schedule
**Purpose**: Protection against accidental deletions and minor disasters

## Tier 2: User Self-Service Image Export

**Location**: `app/controllers/users/image_exports_controller.rb`
**Access**: Navigation → "💾 Backup My Images"
**Format**: ZIP file containing:
- All user's mushroom images
- CSV manifest with EXIF data and metadata
- README with export information

**Features**:
- Background job processing (handles large exports)
- Organized file structure (genus_species_imagename_001.jpg)
- Metadata preservation (GPS, camera settings, dates)
- 24-hour download window
- Automatic cleanup after expiration

**Implementation Files**:
- Controller: `app/controllers/users/image_exports_controller.rb`
- Job: `app/jobs/user_image_export_job.rb`
- Cleanup: `app/jobs/cleanup_export_job.rb`
- Views: `app/views/users/image_exports/`
- Routes: namespace `:users` in `config/routes.rb`

## Tier 3: Automated Offsite Backup (Future)

**Status**: Not yet implemented
**Recommended approach**: Use `rsync` or `rclone` via cron job
**Target options**:
1. Another Hostinger server (simplest)
2. rsync.net ($0.02/GB/month)
3. Backblaze B2 with rclone ($6/TB/month)
4. Any SSH/FTP server

**Recommended implementation**:
```bash
# Daily cron job (3 AM)
0 3 * * * cd /opt/mrdbid/current && RAILS_ENV=production bundle exec rake storage:backup
```

See `lib/tasks/storage_backup.rake` (to be created) for backup task.

## Storage Structure

- **Local storage**: `storage/` directory (linked across deployments via Capistrano)
- **Active Storage**: Uses blob-based system with checksummed subdirectories (00-zz/)
- **Current size**: ~701MB (as of last check)
- **Database tracking**: `active_storage_blobs` and `active_storage_attachments` tables

## Database Exports

**Admin feature**: Database exports exclude the actual blob files
**What's included**: Metadata (attachments, blob references)
**What's NOT included**: Actual image binary data from `storage/`

## Recovery Procedures

### User Image Recovery
1. User downloads export ZIP from "Backup My Images"
2. Extract ZIP to local computer
3. If needed, re-upload images individually to new mushroom observations

### Full Server Recovery (Admin)
1. Restore from Hostinger backup
2. Verify `storage/` directory is intact
3. Verify database connections to blobs are valid
4. Test image display on sample mushroom

## Important Notes

- The `storage/` directory is linked in Capistrano deployments
- Images persist across code deployments
- User export files are stored in `shared/public/tmp/exports/` for 24 hours
- Nginx handles large file downloads via X-Accel-Redirect
- Background jobs use Solid Queue (database-backed)

## AWS S3 Status

**Previous attempt**: Failed and abandoned due to complexity
**Current decision**: Use local storage with manual/automated rsync backups
**Files to remove** (if desired):
- `config/storage.yml` - amazon section
- `lib/tasks/migrate_to_s3.rake`
- AWS credentials from encrypted credentials file

## Monitoring

Check backup health:
```bash
# Storage directory size
du -sh /opt/mrdbid/shared/storage/

# Recent exports
ls -lh /opt/mrdbid/shared/public/tmp/exports/

# Background job status
rails runner "puts SolidQueue::Job.where(queue_name: 'default').count"
```

## Future Enhancements

1. **Email notifications**: Notify users when export is ready
2. **Selective exports**: Allow users to export specific mushrooms/date ranges
3. **Automated offsite backup**: Implement Tier 3 backup strategy
4. **Export history**: Track user export requests
5. **Progress indicators**: Real-time progress for large exports
