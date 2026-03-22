# Rails 8 / Turbo Standard Pattern for Controllers

**Related Standard:** `PROJECT_MEMORY.md` (Authorization & Ownership Rules)

## Critical Rule: NEVER Use respond_to Blocks for Redirects

**Date:** 2026-01-03
**Status:** MANDATORY - All controllers MUST follow this pattern

## The Problem

Previously, we used `respond_to` blocks with `turbo_stream.action(:redirect)` for handling both HTML and Turbo Stream responses:

```ruby
# ❌ BAD - DO NOT USE THIS PATTERN
def update
  if @resource.update(params)
    flash[:notice] = "Resource was successfully updated."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.action(:redirect, @resource)
      end
      format.html { redirect_to @resource, notice: "Resource was successfully updated.", status: :see_other }
    end
  else
    render :edit, status: :unprocessable_entity
  end
end
```

**Why this is wrong:**
1. Flash messages are set in the session but NOT displayed after Turbo Stream redirect
2. Users get no feedback when actions succeed
3. Duplicate code (setting flash twice)
4. Turbo Stream `action(:redirect)` doesn't properly preserve flash messages
5. This pattern has been repeatedly broken and fixed, wasting developer time

## The Solution: Simple redirect_to

Rails 8 with Turbo handles redirects automatically. Just use standard `redirect_to`:

```ruby
# ✅ CORRECT - USE THIS PATTERN
def update
  if @resource.update(params)
    redirect_to @resource, notice: "Resource was successfully updated.", status: :see_other
  else
    render :edit, status: :unprocessable_entity
  end
end
```

**Why this works:**
1. Turbo automatically intercepts the 303 redirect and follows it
2. Flash messages are properly preserved and displayed
3. Single line of code - no duplication
4. Works for both JavaScript-enabled and JavaScript-disabled clients
5. Standard Rails convention - easy to maintain

## Standard Pattern for All Actions

### CREATE Action

```ruby
def create
  @resource = Resource.new(resource_params)

  if @resource.save
    redirect_to @resource, notice: "Resource was successfully created.", status: :see_other
  else
    render :new, status: :unprocessable_entity
  end
end
```

### UPDATE Action

```ruby
def update
  if @resource.update(resource_params)
    redirect_to @resource, notice: "Resource was successfully updated.", status: :see_other
  else
    render :edit, status: :unprocessable_entity
  end
end
```

### DESTROY Action

```ruby
def destroy
  @resource.destroy
  redirect_to resources_path, notice: "Resource was successfully deleted.", status: :see_other
end
```

### Using Service Objects

```ruby
def update
  result = Resources::Updater.call(resource: @resource, params: resource_params)

  if result.success?
    redirect_to result.data, notice: "Resource was successfully updated.", status: :see_other
  else
    render :edit, status: :unprocessable_entity
  end
end
```

## Testing Pattern

Tests should expect standard redirects, NOT turbo_stream responses:

```ruby
# ✅ CORRECT
test "should update resource" do
  patch resource_url(@resource), params: { resource: { name: "New Name" } }

  assert_redirected_to resource_path(@resource)
  assert_equal "Resource was successfully updated.", flash[:notice]
end

# ❌ WRONG - DO NOT USE
test "should update resource with turbo_stream" do
  patch resource_url(@resource),
        params: { resource: { name: "New Name" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

  assert_response :success
  assert_match /turbo-stream action="redirect"/, response.body
end
```

## When respond_to IS Appropriate

`respond_to` blocks are still appropriate for actions that return different representations (JSON API, PDF, etc.):

```ruby
# ✅ This is fine - returning different content types
def show
  respond_to do |format|
    format.html
    format.json { render json: @resource }
    format.pdf { render pdf: "resource_#{@resource.id}" }
  end
end

# ✅ This is fine - API endpoint
def index
  respond_to do |format|
    format.html { @resources = Resource.all }
    format.json { render json: Resource.all }
  end
end
```

**Never use `respond_to` for actions that redirect (create, update, destroy).**

## Flash Message Pattern

### For Redirects (create, update, destroy)

```ruby
# Pass notice/alert as parameter to redirect_to
redirect_to @resource, notice: "Success message", status: :see_other
redirect_to @resource, alert: "Error message", status: :see_other
```

### For Renders (new, edit with errors)

```ruby
# No flash needed - errors are in @resource.errors
render :edit, status: :unprocessable_entity
```

## View Requirements

Forms should use standard `form_with`:

```erb
<%# ✅ CORRECT - Turbo handles this automatically %>
<%= form_with(model: @resource) do |f| %>
  <%# form fields %>
  <%= f.submit %>
<% end %>

<%# ❌ WRONG - Don't disable Turbo unless absolutely necessary %>
<%= form_with(model: @resource, data: { turbo: false }) do |f| %>
  ...
<% end %>
```

## Confirmation Dialogs

Use `data: { turbo_confirm: "..." }` for delete buttons:

```erb
<%# ✅ CORRECT %>
<%= button_to "Delete",
              resource_path(@resource),
              method: :delete,
              data: { turbo_confirm: "Are you sure?" },
              class: "btn-danger" %>

<%# ❌ WRONG - Don't use onsubmit or data: { turbo: false } %>
<%= button_to "Delete",
              resource_path(@resource),
              method: :delete,
              form: { onsubmit: 'return confirm("Are you sure?")', data: { turbo: false } } %>
```

## Controllers Fixed (2026-01-03)

All of these controllers now follow the standard pattern:

1. `app/controllers/mushrooms_controller.rb` - create, update, destroy
2. `app/controllers/mr_character_mushrooms_controller.rb` - create
3. `app/controllers/image_mushrooms_controller.rb` - destroy
4. `app/controllers/projects_controller.rb` - create, update, destroy
5. `app/controllers/all_groups_controller.rb` - create, update, destroy
6. `app/controllers/clusters_controller.rb` - create, update, destroy
7. `app/controllers/mushroom_projects_controller.rb` - create, update, destroy
8. `app/controllers/all_group_mushrooms_controller.rb` - create, update, destroy
9. `app/controllers/cluster_mushrooms_controller.rb` - create, update, destroy
10. `app/controllers/users_controller.rb` - create, update, destroy

**Total: 28 actions standardized**

## Checklist for New Controllers

When creating a new controller, ensure:

- [ ] Create action uses `redirect_to` with `notice:` parameter
- [ ] Update action uses `redirect_to` with `notice:` parameter
- [ ] Destroy action uses `redirect_to` with `notice:` parameter
- [ ] No `respond_to` blocks in create/update/destroy
- [ ] No `flash[:notice] =` before redirects
- [ ] Tests use `assert_redirected_to`, not `assert_response :success`
- [ ] Forms use standard `form_with` with Turbo enabled
- [ ] Delete buttons use `data: { turbo_confirm: "..." }`

## References

- Rails 8 Turbo Documentation: https://turbo.hotwired.dev/
- Rails Guides - Working with JavaScript: https://guides.rubyonrails.org/working_with_javascript_in_rails.html
- This pattern was established after multiple incidents of broken flash messages (see commits)
- **Related Standard**: See `IPAD_IMAGE_LOADING.md` for image loading requirements

## History of This Issue

This pattern was established after repeated issues where flash messages weren't displayed:

1. **Multiple previous fixes** - Color picker, image delete, various CRUD actions
2. **Root cause identified** - Commit c541d23 removed respond_to blocks but they were re-added incorrectly
3. **Final fix (2026-01-03)** - Removed ALL respond_to blocks from redirect actions
4. **Result** - Simple, maintainable, standard Rails 8 pattern

**If you're tempted to add a respond_to block to a redirect action, DON'T. Read this document first.**
