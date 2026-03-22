# Rails Engine Setup Guide

## Problem: Mounted Rails Engines Get Blocked by Pundit

Our ApplicationController has `after_action :verify_authorized` which applies to ALL controllers, including those from mounted Rails engines (gems). This causes 401 errors on engine routes.

## Solution: Skip Pundit for Engine Controllers

When mounting a new Rails engine (e.g., `mount SomeEngine::Engine => "/path"`), you MUST skip Pundit verification for its controllers.

### Steps:

1. **Create an initializer** in `config/initializers/[engine_name].rb`:

```ruby
# config/initializers/auto_glossary.rb
Rails.application.config.to_prepare do
  AutoGlossary::GlossaryController.class_eval do
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped
  end
end
```

2. **Restart the server** after creating the initializer

3. **Test the engine routes** work without authentication

### Why This Happens:

- `ApplicationController` applies Pundit globally (app/controllers/application_controller.rb:32-33)
- Mounted engines inherit from their own base controllers, not ApplicationController
- But Rails still runs ApplicationController callbacks on engine controllers
- Engine controllers don't call `authorize`, so Pundit raises `Pundit::NotAuthorizedError` → 401

### Affected Engines:

- ✅ auto_glossary (fixed: config/initializers/auto_glossary.rb)

### Future Engine Checklist:

When adding a new Rails engine:

- [ ] Add engine to Gemfile
- [ ] Run `bundle install`
- [ ] Mount engine in `config/routes.rb`
- [ ] **Create initializer to skip Pundit** ← DON'T FORGET THIS
- [ ] Restart server
- [ ] Test engine routes work without authentication
- [ ] Document in this file under "Affected Engines"

### Testing Engine Routes:

```bash
# Local test
curl http://localhost:3000/engine-path/endpoint

# Production test
curl https://mrdbid.com/engine-path/endpoint
```

Should return 200, not 401.
