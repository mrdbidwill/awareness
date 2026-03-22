# Decision Log

Short, durable records of decisions that affect architecture, behavior, or long-term maintenance.

## Template

- Date: YYYY-MM-DD
- Decision:
- Rationale:
- Consequences:
- Alternatives Considered:

## Entries

- Date: 2026-03-20
- Decision: Replace legacy `mr_characters.core_sequence` ordering with per-fungus-type sequencing stored in `core_character_sequences`.
- Rationale: Core order must be configurable by fungus type and reusable across core-only entry/search/display flows.
- Consequences: Legacy per-character sequence field is removed; ordering is now managed from the admin sequence page and applied by fungus type.
- Alternatives Considered: Keep global `core_sequence` column; rejected because it cannot represent fungus-type-specific order.

- Date: 2026-03-20
- Decision: Add a preflight script and enforce rbenv initialization (Ruby 3.4.3, Bundler 2.6.9) before running tests.
- Rationale: Prevent test failures caused by the wrong Ruby/Bundler context and align execution with documented runtime expectations.
- Consequences: Tests now have a standard preflight check (`script/preflight_test_env.sh`) and require rbenv initialization in automated runs.
- Alternatives Considered: Rely on developer memory and README instructions; rejected due to repeatable failures.

- Date: 2026-03-14
- Decision: Add a sidebar link to `Export My Images`.
- Rationale: Improve discoverability for image backup/export without relying on direct URLs.
- Consequences: Users can start image exports from the main navigation; no behavior change to the export job itself.
- Alternatives Considered: Keep export link hidden in the page-only flow; rejected for UX clarity.

- Date: 2026-03-14
- Decision: Replace `data-confirm` with `data-turbo-confirm` for confirmation prompts across Turbo-driven views.
- Rationale: `@hotwired/turbo-rails` is loaded without rails-ujs, so `data-confirm` does not trigger a browser confirm dialog.
- Consequences: All destructive/confirm actions now consistently show confirmation prompts under Turbo.
- Alternatives Considered: Reintroduce rails-ujs; rejected to keep the JS stack minimal.

- Date: 2026-03-14
- Decision: Enforce demo-only access for public mushroom/image show pages and require Pundit authorization on show actions.
- Rationale: Align runtime behavior with the documented public/demo boundary and prevent unintended data exposure.
- Consequences: Guest requests to non-demo show pages now redirect with authorization messaging.
- Alternatives Considered: Leave show pages open to public; rejected due to privacy and policy drift.

- Date: 2026-03-14
- Decision: Serialize PDF/image exports per user using cache-based active export locks.
- Rationale: Avoid duplicate long-running export jobs and reduce queue pressure without removing features.
- Consequences: Users can queue one active export at a time (10-minute reentry window).
- Alternatives Considered: Dedicated database table; deferred for simplicity.

- Date: 2026-03-01
- Decision: Consolidate documentation into `docs/`, add `PROJECT_MEMORY.md`, and introduce this decision log.
- Rationale: Reduce regressions by centralizing institutional knowledge and making updates routine.
- Consequences: Docs moved from repo root to `docs/`, references updated, and `README.md` points to the index.
- Alternatives Considered: Leave docs distributed in root; rejected due to discoverability and drift.
