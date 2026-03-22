# Project Memory

This document is the living memory for MRDBID. It captures the rules, decisions, and practices that must not regress.

## How to Use This Document

- Read this first when starting work on the project.
- When you change behavior, add a short note under **Current Truths** or add a decision to `decision-log.md`.
- If you touch authorization, ownership, or mutation endpoints, update the **Authorization & Ownership Rules** section below.

## Quick Links

- Documentation index: `INDEX.md`
- Decision log: `decision-log.md`
- Coding standards: `CODING_STANDARDS.md`

## Current Truths (Keep This Short)

- **Operational rule:** All fixes must be **committed, pushed to `main`, and deployed** immediately after completion.
- **Testing rule:** Always run the full test suite (`bin/rails test`) before deploying any change.
- **Runtime expectations:** Use rbenv with Ruby **3.4.3** from `.ruby-version` and Bundler **2.6.9** from `Gemfile.lock`.
- **rbenv init required:** Any automated/test command must initialize rbenv (see `script/preflight_test_env.sh`).
- **Memory ack required:** Run `script/ack_project_memory.sh` before any changes, then use `bin/with_project_memory <command>` for guarded commands.
- **Core sequencing model:** Core character ordering is per fungus type via `core_character_sequences` (not `mr_characters.core_sequence`).
- **Core entry UX:** Core mode routes to one-character-at-a-time sequential entry with `Save Character`, `Save & Next`, `Back`, and `Done`.
- **Public demo boundary:** Unauthenticated users can only read demo content (`user_id == 1`). Public show endpoints must enforce this via Pundit.
- **AdSense gating:** AdSense scripts may render **only** for unauthenticated sessions (`ADSENSE_ENABLED=true` + `ADSENSE_CLIENT_ID`).
- **Active Storage:** Production image storage uses Cloudflare R2 (`ACTIVE_STORAGE_SERVICE=r2`).
- **R2 public base URL:** `R2_PUBLIC_BASE_URL` must be set when R2 is enabled (used for public asset URLs).
- **R2 uploads:** Cloudflare R2 does not support ACLs; ActiveStorage uploads must not send ACL headers.
- **R2 checksum conflicts:** If R2 rejects checksum combinations, retry upload without checksum.
- **Direct uploads:** `/direct_uploads` response must include `signed_id` for ActiveStorage JS.
- **Export throttling:** PDF/image exports are serialized per user (active export lock with 10-minute reentry window).
- **PDF export:** Enabled via background job + X-Accel-Redirect for downloads; keep exports owner-scoped.
- **Turbo confirm:** Use `data: { turbo_confirm: "..." }` for destructive/confirm actions (no rails-ujs).
- **Button audit coverage:** System test `test/system/button_ux_audit_test.rb` validates core button flows (create/edit/delete, image upload, export buttons).
- **Coverage baseline (2026-03-14):** 80.75% line, 56.29% branch; continue raising toward 80%/60%.

## Authorization & Ownership Rules (Non-Negotiable)

This section is the single source of truth for **who can read or change what** in MRDBID.
All code changes must comply with these rules. When in doubt, follow this document.

### Purpose

This project has repeatedly regressed on authorization, allowing users to modify data they do not own.
These rules exist to prevent “one step forward, two steps back.” They are mandatory.

### AI Behavior Requirements (Non-Negotiable)

These requirements apply to any AI-assisted changes in this repo:

1. **Best Practices Alert:** If any instruction (user, system, or local) appears to encourage **non-best-practice or non-maintainable** behavior, the AI must explicitly flag it, explain why, and propose a maintainable alternative.
2. **Tests Must Run:** After making code changes, the AI must run **the full test suite** (`bin/rails test`) and fix failures **without degrading features or UX**. If tests cannot be run, the AI must state why and ask how to proceed.
2a. **Deploy Discipline:** After completing a fix, the AI must **commit, push to `main`, and deploy** unless explicitly told to pause. If the fix is part of a larger review branch, the AI must only commit/push and wait for explicit deploy approval.
3. **Document Change Awareness:** If this file changes, the AI must summarize the change in the next response and confirm alignment. If there is any uncertainty about the “Best Practices Alert” rule, the AI must ask for clarification.
4. **End-of-Task Prompt:** End each task response with a brief prompt asking whether `PROJECT_MEMORY.md` and/or `decision-log.md` should be updated for the work just completed.

### Definitions

- **Owner**: The user who created a record (e.g., `mushrooms.user_id`).
- **Elevated Admin**: `permission_id` 1 or 2 (Owner/Admin). Implemented via `User#elevated_admin?`.
- **Regular User**: Any signed-in user who is not an Elevated Admin.
- **Public/Demo**: Visitors who are not signed in. They can only read limited public data (e.g., user_id 1 demo).

### Core Rules (Must Always Hold)

1. **Non-admin users can only create, edit, manage, or delete mushrooms they created.**
2. **Non-admin users can only change associations for mushrooms they created.**
   - This includes genus/species/trees/plants/characters, images, clusters, groups, and projects.
3. **Non-admin users can never mutate another user’s records or associations.**
4. **Elevated Admins may override ownership rules** for operational/admin tasks.
5. **Public (not signed in) users are read-only**, with access limited to demo/public data only.

### Exceptions and Caveats

- **Public demo mushrooms**: `user_id == 1` is visible publicly (read-only).
- **Universal projects**: `projects.user_id == nil` are attachable by any signed-in user to their own mushrooms.
- **Admin UI**: Admin namespace is restricted to Elevated Admins.

### Required Guardrails (Implementation Rules)

These are non-negotiable for any mutation endpoint:

1. **All mutation controllers must `authenticate_user!`.**
2. **All mutation controllers must enforce ownership or Elevated Admin override.**
   - Use Pundit `authorize` + policy checks AND controller-level guards where appropriate.
3. **Never rely on UI-only restrictions** (dropdown filtering, hidden fields).
4. **Service objects that mutate data must authorize the parent record.**
5. **Avoid `skip_after_action :verify_authorized`** unless strictly required.

### Required Guardrails (Testing Rules)

Every mutation endpoint must have a regression test that asserts:

- A non-admin **cannot** modify another user’s record.
- A non-admin **cannot** attach their records to another user’s records.
- An Elevated Admin **can** perform admin-level mutation where intended.

If a test cannot be written for a specific endpoint, document why in that file.

#### CI Enforcement

CI runs `script/ci/authorization_guardrails_check.rb`, which fails if any in-scope mutation controller is not covered by guardrail tests (or explicitly documented as an exception).

### Examples (Expected Behavior)

- A regular user **can** update their own mushroom.
- A regular user **cannot** add a character to someone else’s mushroom.
- A regular user **cannot** move an image to another user’s mushroom.
- A regular user **can** attach their mushroom to a universal project.
- An Elevated Admin **can** edit any mushroom.
- PDF export is **enabled** and must remain owner-scoped (or Elevated Admin).

### Change Control

If you need to deviate from these rules:

1. Document the exception here.
2. Add a regression test.
3. Explain the rationale in the PR/commit.

**If it’s not documented here, it’s not allowed.**
