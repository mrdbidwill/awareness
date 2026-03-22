# MrDbId Coding Standards

**Last Updated:** 2026-01-04

This document serves as the index to all mandatory coding standards for the MrDbId application. **ALL standards listed here are MANDATORY** and must be followed for all new code and code modifications.

## ⚠️ Critical Standards (Read These First)

These standards were created after recurring bugs that wasted significant development time. Violating these standards will likely reintroduce bugs that have already been fixed multiple times.

### 0. Authorization & Ownership Rules (Project Memory)
**File:** `PROJECT_MEMORY.md`
**Status:** MANDATORY
**Created:** 2026-02-27

**Summary:** Non-admin users can only create/edit/delete their own mushrooms and their own mushroom associations. Elevated Admins (permission_id 1–2) may override ownership rules. Public users are read-only. This document is the single source of truth for all authorization rules.

**Why:** Ownership regressions have occurred repeatedly due to missing or inconsistent authorization checks across mutation endpoints. This standard exists to prevent reintroducing those bugs.

### 1. Rails 8 / Turbo Controller Pattern
**File:** `RAILS_8_TURBO_STANDARD_PATTERN.md`
**Status:** MANDATORY
**Created:** 2026-01-03

**Summary:** Never use `respond_to` blocks with `turbo_stream.action(:redirect)` in create/update/destroy actions. Always use simple `redirect_to` with the `notice:` parameter. Rails 8 / Turbo automatically handles these redirects and preserves flash messages.

**Why:** This issue was fixed multiple times. Using `respond_to` blocks causes flash messages to not display, leaving users with no feedback after form submissions.

### 2. iPad Image Loading Pattern
**File:** `IPAD_IMAGE_LOADING.md`
**Status:** MANDATORY
**Created:** 2026-01-04 (after 2nd occurrence)

**Summary:** Never use `loading="lazy"` for mushroom images. Always use `loading="eager"` and `fetchpriority="high"`. Safari on iPad has a bug where lazy-loaded images don't load when navigating via Turbo, showing blue question mark squares instead.

**Why:** This issue was fixed twice (2026-01-01, 2026-01-04). Lazy loading breaks image display on iPad, a critical device for field use.

### 3. PDF Export User Feedback Pattern
**File:** `PDF_EXPORT_FEEDBACK.md`
**Status:** MANDATORY
**Created:** 2026-01-13 (after 4th+ occurrence)

**Summary:** The "Export All to PDF" button MUST have a loading overlay and feedback mechanism. PDF generation takes 10-60+ seconds. Without visual feedback, users think the button is broken and click multiple times or navigate away. The implementation requires: (1) a confirmation dialog via `data-turbo-confirm`, (2) button state change to "⏳ Exporting...", (3) a full-screen loading overlay with spinner and "do not navigate away" message, and (4) automatic cleanup after 3 seconds minimum.

**Why:** This issue has been fixed and then accidentally removed/simplified MULTIPLE times (commits 3a307ae, 096e678, 1f7a688, then broken again in 6abce02). Each time it's removed, users report the button as "not working" because there's no feedback during the 10-60 second PDF generation. DO NOT SIMPLIFY OR REMOVE THIS CODE.

**Location:** `app/views/shared/_sidebar.html.erb` lines 85-278

### 4. Genus Display Fallback Pattern
**Status:** MANDATORY
**Created:** 2026-01-14 (after 2nd occurrence)

**Summary:** When displaying identifications from `ranked_identifications`, ALWAYS use the genus fallback pattern: `(id[:genus]&.name || id[:species]&.genus&.name || '?')`. Never use just `id[:genus]&.name || '?'`. The `ranked_identifications` method pairs genera and species by array index, which can create mismatches when species are added in different orders. Species always have a `genus_id` foreign key, so falling back to `id[:species]&.genus&.name` provides the correct genus name even when the pairing is off.

**Why:** Fixed in commit ca3f9ab for edit view, but the same pattern was missing in the show view (`_mushroom.html.erb`), causing "?" to display instead of genus names (e.g., "? betulinus" instead of "Lenzites betulinus"). All views that display identifications must use this pattern consistently.

**Locations:**
- `app/views/mushrooms/edit.html.erb` (lines around genus display)
- `app/views/mushrooms/_form.html.erb` (candidate summary section)
- `app/views/mushrooms/_mushroom.html.erb` (identification display - lines 40, 45)

## Code Review Checklist

Before merging any PR, verify:

### Controllers (create/update/destroy actions)
- [ ] Uses simple `redirect_to` with `notice:` or `alert:` parameter
- [ ] Does NOT use `respond_to` blocks for redirects
- [ ] Does NOT have `flash[:notice] =` before redirect
- [ ] Tests use `assert_redirected_to`, not turbo_stream assertions

### Authorization (All mutation endpoints)
- [ ] Follows `PROJECT_MEMORY.md` ownership rules
- [ ] Uses `authenticate_user!` for all mutation actions
- [ ] Enforces Pundit authorization for the parent record
- [ ] Has a regression test proving non-owners cannot mutate

### Views (image display)
- [ ] All mushroom images use `loading="eager"`
- [ ] All mushroom images use `fetchpriority="high"`
- [ ] No instances of `loading="lazy"` in mushroom-related views

### PDF Export (in _sidebar.html.erb)
- [ ] "Export All to PDF" button has `data-turbo-confirm` attribute
- [ ] JavaScript handler creates loading overlay with spinner
- [ ] Button changes to "⏳ Exporting..." during generation
- [ ] Overlay shows "do not navigate away" message
- [ ] Code has CRITICAL warning comments not to remove/simplify

### Identification Display
- [ ] Uses genus fallback pattern: `(id[:genus]&.name || id[:species]&.genus&.name || '?')`
- [ ] Pattern applied consistently across all views that display identifications
- [ ] Never use simplified version: `id[:genus]&.name || '?'`

### Forms
- [ ] Standard `form_with` with Turbo enabled (default)
- [ ] Delete buttons use `data: { turbo_confirm: "..." }`
- [ ] No `data: { turbo: false }` unless absolutely necessary

### Tests
- [ ] All controller tests pass (run `bin/rails test`)
- [ ] New features have corresponding tests
- [ ] Tests follow existing patterns in test suite

### Documentation Memory
- [ ] Updated `PROJECT_MEMORY.md` and/or `decision-log.md` for notable changes

## Development Workflow

### Before Starting Work
1. Read the relevant standard documents above
2. Check for existing patterns in the codebase
3. Ask if unsure about the correct approach

### Before Committing
1. Run full test suite: `bin/rails test`
2. Check for lazy loading: `grep -r 'loading: "lazy"' app/views/`
3. Check for respond_to blocks in CRUD: `grep -r 'respond_to do |format|' app/controllers/ | grep -E '(create|update|destroy)'`
4. Review your changes against the standards
5. Update `PROJECT_MEMORY.md` and/or `decision-log.md` when behavior or patterns change

### Commit Messages
- Reference the standard if following a documented pattern
- Explain WHY not just WHAT
- Include test results if applicable

## Additional Documentation

### Authorization (Single Source of Truth)
- `PROJECT_MEMORY.md` - Authorization and ownership rules (MUST FOLLOW)

### Documentation Home
- `INDEX.md` - Documentation index (start here)
- `decision-log.md` - Architectural and process decisions

### Feature Documentation
- `COMPARISON_FEATURE.md` - Mushroom comparison functionality
- `FUNGUS_TYPE_FLEXIBILITY_REFACTORING.md` - Fungus type architecture
- `CAMERA_INTEGRATION_COMPLETE.md` - Camera/EXIF integration
- `CAMERA_EQUIPMENT_SUMMARY.md` - Camera equipment features
- `COLOR_SYSTEM.md` - Hybrid color system (77 colors: 27 simplified + 50 AMS)

### Performance & Optimization
- `OPTIMIZATION_SUMMARY.md` - Performance improvements
- `PERFORMANCE_OPTIMIZATION_PLAN.md` - Performance strategy

### Testing
- `TESTING_QUICK_START.md` - How to run tests
- `TEST_SUITE_COMPLETE_SUMMARY.md` - Test suite overview
- `TESTING_IMPROVEMENTS_SUMMARY.md` - Testing best practices

### Deployment
- `DEPLOYMENT.md` - Deployment process
- `DEPLOYMENT_CHECKLIST.md` - Post-deploy verification and service restarts
- `DEPLOYMENT_NOTES.md` - Systemd service templates and reference notes
- `DEPLOYMENT_TROUBLESHOOTING.md` - Common deployment issues
- `SERVER_BACKUP_INSTRUCTIONS_10_13_2025.md` - Backup procedures

### Production Issues
- `PRODUCTION_500_ERROR_FIX.md` - N+1 query fix
- `PRODUCTION_500_ERROR_FIX_ACTUAL.md` - Strict loading implementation
- `STRICT_LOADING_PATTERN.md` - Strict loading association preloading patterns

### Infrastructure
- `SOLID_QUEUE_SETUP.md` - Background job configuration

## Why These Standards Exist

This project has experienced several recurring bugs that were:
1. Fixed
2. Broken again by new code
3. Re-fixed (wasting time and money)
4. Sometimes broken a third time

The two critical standards (Turbo patterns and image loading) were created specifically to prevent this cycle. **Following these standards is not optional.**

## When to Update Standards

Update or create new standard documents when:
- A bug is fixed for the 2nd time (indicates need for documentation)
- A new pattern is established as "the right way"
- A Rails/framework upgrade requires pattern changes
- A cross-cutting concern affects multiple areas of the codebase

## Getting Help

If you're unsure about the correct pattern:
1. Check this document and the referenced standards
2. Search the codebase for similar existing code
3. Check git history: `git log --all --grep="pattern_name"`
4. Ask before implementing if still unclear

## Standard Document Template

When creating a new standard document, include:

1. **The Problem** - What breaks and why
2. **The Solution** - The correct pattern to use
3. **Examples** - Both correct and incorrect code
4. **Why** - Explanation of why this is the right approach
5. **History** - When/why this became a standard
6. **Checklist** - Quick verification steps

**Remember: These standards exist because we've already paid the cost of learning these lessons. Don't make us pay again.**
