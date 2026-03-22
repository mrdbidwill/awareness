# Strict Loading Pattern - Rails 8 Association Preloading

**Last Updated:** 2026-01-14
**Status:** MANDATORY

## The Problem

Rails 8 has `strict_loading_by_default = true` enabled (see `config/application.rb:44`). This prevents lazy loading of associations and raises `ActiveRecord::StrictLoadingViolationError` when code tries to access an association that wasn't preloaded.

### Common Symptom

```
ActionView::Template::Error: `Species` is marked for strict_loading.
The Genus association named `:genus` cannot be lazily loaded.
```

This error appears in production when:
1. A controller loads a record with `.includes(:association)`
2. But a view or model method accesses a **nested** association (like `species.genus`)
3. The nested association wasn't included in the preload

## The Solution

**ALWAYS preload nested associations** that will be accessed in views or model methods.

### Pattern 1: Controller Preloading

```ruby
# ❌ WRONG - Only preloads species, not species.genus
@mushroom = Mushroom.includes(:species).find(params[:id])

# ✅ CORRECT - Preloads species AND its genus association
@mushroom = Mushroom.includes(species: :genus).find(params[:id])
```

### Pattern 2: Model Method Preloading

When a model method returns associated records that will be accessed in views:

```ruby
# ❌ WRONG - in app/models/mushroom.rb
def ranked_identifications
  species_records = mushroom_species.includes(:species)
  # View will access species.genus.name → FAILS!
end

# ✅ CORRECT
def ranked_identifications
  species_records = mushroom_species.includes(species: :genus)
  # View can now access species.genus.name safely
end
```

### Pattern 3: Multiple Nested Levels

```ruby
# Preload deeply nested associations
@records = Model.includes(
  association1: :nested1,
  association2: { nested2: :deeply_nested }
)
```

## Why This Matters

1. **Strict loading prevents N+1 queries** - Forces us to think about performance up front
2. **Only breaks in production** - Works in development/test without strict_loading
3. **Hard to debug** - Error doesn't say WHERE to add the preload
4. **Cascading failures** - One missing preload can break multiple pages

## Real-World Example: The Mushroom Species Bug (2026-01-14)

### The Bug

- Mushroom 143 had 2 species (ids 91636, 91638)
- Mushroom 62 had 1 species (id 36559)
- Clicking "Edit - Add Characters" worked for mushroom 62, failed for 143
- Error: "Species is marked for strict_loading. The Genus association cannot be lazily loaded."

### The Root Cause

**File:** `app/models/mushroom.rb:140`

```ruby
# ❌ WRONG
def ranked_identifications
  species_records = mushroom_species.includes(:species)
  # ...
end
```

**File:** `app/views/mushrooms/edit.html.erb:30`

```ruby
<% identifications.each do |id| %>
  <% genus_name = id[:genus]&.name || id[:species]&.genus&.name || '?' %>
  <%# ^^^^^^^^^^^^^^^^^^^^^^^ This line accessed species.genus %>
<% end %>
```

### Why It Only Failed for Mushroom 143

- Mushroom 62 had 1 species → loop ran once
- Mushroom 143 had 2 species → loop ran twice, accessing `species.genus` multiple times
- The iteration over multiple records exposed the missing preload

### The Fix

```ruby
# ✅ CORRECT - app/models/mushroom.rb:141
def ranked_identifications
  species_records = mushroom_species.includes(species: :genus)
  # Now the view can safely access species.genus.name
end
```

**Commit:** 8e4fbac "Fix strict_loading: Preload genus in ranked_identifications"

## Debugging Checklist

When you see a strict_loading error:

1. **Read the error carefully** - It tells you WHICH association is missing
2. **Find where it's accessed** - Search views/partials for the association name
3. **Trace back to the controller/model** - Find where the parent record is loaded
4. **Check for nested access** - Look for patterns like `record.association.nested`
5. **Add the nested preload** - Use `includes(association: :nested)`

### Common Mistake: Pundit Policies

```ruby
# ❌ WRONG - scope.all discards includes
class SpeciesPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.none
    end
  end
end

# ✅ CORRECT - scope preserves includes
class SpeciesPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope : scope.none
    end
  end
end
```

Using `scope.all` creates a **new query** and discards any `.includes()` preloads from the controller.

## Testing for Strict Loading Violations

```ruby
# In your test environment, strict_loading is enabled by default
# Tests will fail if associations aren't preloaded

test "should not violate strict_loading when showing mushroom" do
  mushroom = mushrooms(:one)
  get mushroom_path(mushroom)
  assert_response :success
  # If this passes, all associations are properly preloaded
end
```

## Git History Reference

Key commits that fixed strict_loading issues:

- `8e4fbac` - Fix ranked_identifications preloading (2026-01-14)
- `c52e80c` - Fix SpeciesPolicy scope.all issue (2026-01-14)
- `9781ebc` - Fix Species index preloading (2026-01-14)
- `ba247e5` - Fix Species edit preloading (2026-01-14)
- `ca3f9ab` - Fix identification UX genus display (2026-01-13)

Search history: `git log --all --grep="strict_loading"`

## Prevention

1. **Always think nested** - If you load an association, ask "will the view access nested associations?"
2. **Use Rails console in production mode** - Test with `RAILS_ENV=production rails console`
3. **Check logs** - Strict loading errors appear in `production.log`
4. **Review views** - Search for chained associations like `.association.nested.name`

## When to Disable Strict Loading (Rarely!)

Only disable for specific cases like background jobs (see `config/application.rb:48-54`):

```ruby
# Relax strict loading for background jobs
config.active_job.around_perform do |_job, block|
  original_mode = ActiveRecord.strict_loading_mode
  ActiveRecord.strict_loading_mode = :n_plus_one_only
  block.call
ensure
  ActiveRecord.strict_loading_mode = original_mode
end
```

**Never disable globally** - Strict loading protects production performance.

---

**Remember:** Strict loading is your friend. It forces good practices and prevents performance problems. The pain of fixing preloading issues is far less than the pain of N+1 queries in production.
