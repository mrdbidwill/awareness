# frozen_string_literal: true

# Core permissions used by the simplified editorial/admin workflow.
[
  { id: 1, name: 'Super Admin', description: 'Full system access' },
  { id: 2, name: 'Admin', description: 'Administrative access' },
  { id: 5, name: 'Editor', description: 'Can edit content' },
  { id: 9, name: 'User', description: 'Standard user access' }
].each do |attrs|
  Permission.find_or_create_by!(id: attrs[:id]) do |permission|
    permission.name = attrs[:name]
    permission.description = attrs[:description]
  end
end
