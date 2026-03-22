# frozen_string_literal: true

# Monkey patch for carmen gem compatibility with Ruby 3.2+
# File.exists? was removed in Ruby 3.2, replaced with File.exist?

# Patch File class to add back exists? method temporarily
class File
  class << self
    alias_method :exists?, :exist? unless method_defined?(:exists?)
  end
end
