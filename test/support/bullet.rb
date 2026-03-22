# test/support/bullet.rb
# Bullet configuration for N+1 query detection in tests

if defined?(Bullet)
  Bullet.enable = true
  Bullet.bullet_logger = true
  Bullet.raise = false # Don't raise errors yet, just log them

  # Add filters if needed
  # Bullet.add_whitelist type: :n_plus_one_query, class_name: "User", association: :posts
end
