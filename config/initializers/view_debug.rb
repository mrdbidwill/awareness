# config/initializers/view_debug.rb
# Collect rendered partial identifiers in dev/test only
if Rails.env.development? || Rails.env.test?
  ActiveSupport::Notifications.subscribe("render_partial.action_view") do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    id = event.payload[:identifier]
    next unless id

    views_root = Rails.root.join("app", "views").to_s
    next unless id.start_with?(views_root)

    Thread.current[:rendered_partials] ||= []
    Thread.current[:rendered_partials] << id.sub("#{Rails.root}/", "")
  end
end
