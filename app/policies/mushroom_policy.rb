class MushroomPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < ApplicationPolicy::Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5


  class Scope < ApplicationPolicy::Scope
    # Only show mushrooms that belong to the current user
    def resolve
      scope.where(user: user)
    end

    # For advanced search - allow searching across all users' mushrooms
    def resolve_all
      scope.all
    end
  end

  # Shared logic to check if the current user owns the mushroom
  def owner?
    user.present? && record.user_id == user.id
  end

  # Shared logic to check if user is owner or admin
  def owner_or_admin?
    user.present? && (record.user_id == user.id || user.elevated_admin?)
  end



  # Allow index for all signed-in users
  def index?
    user.present?
  end

  # Allow any signed-in user to view any mushroom, OR allow public to view user_id=1 (demo) mushrooms
  def show?
    user.present? || record.user_id == 1
  end

  def edit?
    owner_or_admin?
  end

  # Allow editing characters if the mushroom is owned by the current user or user is admin
  def edit_characters?
    owner_or_admin?
  end

  # Allow create if the user is signed in
  def create?
    user.present?
  end

  # Allow update if the mushroom is owned by the current user or user is admin
  def update?
    owner_or_admin?
  end

  # Allow destroy if the mushroom is owned by the current user or user is admin
  def destroy?
    owner_or_admin?
  end

  def mushroom_image_mushroom?
    owner_or_admin?
  end

  # Allow adding to a group if owner or admin
  def all_group_mushroom?
    owner_or_admin?
  end

  # Allow adding to a cluster if owner or admin
  def mushroom_cluster?
    owner_or_admin?
  end

  # Allow adding to a project if owner or admin
  def mushroom_project?
    owner_or_admin?
  end

  # Allow PDF export if user owns the mushroom or is admin
  def export_pdf?
    owner_or_admin?
  end

  # Allow cloning characters if user owns the mushroom or is admin
  def clone_characters?
    owner_or_admin?
  end

end
