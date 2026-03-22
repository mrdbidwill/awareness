# frozen_string_literal: true

# Background job to clean up old export files
class CleanupExportJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    return unless file_path.present?

    if File.exist?(file_path)
      File.delete(file_path)
      Rails.logger.info "[CleanupExportJob] Deleted export file: #{file_path}"
    else
      Rails.logger.info "[CleanupExportJob] File already deleted: #{file_path}"
    end
  rescue => e
    Rails.logger.error "[CleanupExportJob] Failed to delete #{file_path}: #{e.message}"
  end
end
