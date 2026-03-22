# Disable strict_loading for Solid Queue internal models
# Solid Queue's internal operations require lazy loading associations
Rails.application.config.to_prepare do
  SolidQueue::Job.strict_loading_mode = :n_plus_one_only if defined?(SolidQueue::Job)
  SolidQueue::Process.strict_loading_mode = :n_plus_one_only if defined?(SolidQueue::Process)
  SolidQueue::ClaimedExecution.strict_loading_mode = :n_plus_one_only if defined?(SolidQueue::ClaimedExecution)
end
