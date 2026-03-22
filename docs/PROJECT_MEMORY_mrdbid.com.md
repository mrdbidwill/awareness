# Project Memory - mrdbid.com

Purpose: continuity log for monetization and storage migration planning when direct repo access is unavailable.

## 2026-03-11
- Target direction confirmed:
  - move observation/user-upload image storage to Cloudflare R2
  - use direct browser uploads via presigned URLs
  - keep app servers for metadata/auth/business logic only
- Ad strategy confirmed:
  - ads on anonymous/public pages
  - never load AdSense script for authenticated sessions
- Next implementation entry required in mrdbid.com repo when accessible:
  - storage adapter + presign endpoint
  - background dominant-color extraction + cached DB field for sort
  - public/auth layout ad split

## 2026-03-12
- Cross-project rollout feedback from `myDNAobv` production run:
  - all-photo export modes can sharply increase queue runtime and resource pressure; start `mrdbid` rollout with conservative caps and explicit throttling.
  - generated file naming should be context-specific (avoid generic repeated names) for better user/download UX.
  - keep a manual deploy fallback path documented; CI deploy failures can produce noise even when live service is healthy.
- RubyMine handoff doc was revalidated and updated to explicitly call out quota-wait and split-output fallback as expected under heavy load.

## 2026-03-14
- `mrdbid` image storage migration is complete:
  - ActiveStorage R2 service enabled (`ACTIVE_STORAGE_SERVICE=r2`).
  - Direct uploads configured via `/direct_uploads` and R2 public base URL.
  - Backfill task available (`r2:backfill`) for legacy disk blobs.
- Public/demo boundary tightened:
  - Guests can only access demo content (`user_id == 1`) for mushroom and image show pages.
- AdSense gating is in code:
  - Public-only script rendering via `ADSENSE_ENABLED=true` + `ADSENSE_CLIENT_ID`.
  - Authenticated sessions never render AdSense markup.
- Next operational step is to flip the AdSense env flags once ready to go live.
- Button/UX audit coverage added:
  - New system test `test/system/button_ux_audit_test.rb` exercises core create/edit/delete, image upload, and export buttons.
- Turbo confirm alignment:
  - Destructive/confirm actions now use `data: { turbo_confirm: "..." }` (no rails-ujs dependency).
- Export navigation:
  - Sidebar now includes a direct link to `Export My Images` (`new_users_image_export_path`).
- Coverage checkpoint:
  - 80.75% line, 56.29% branch (SimpleCov).

## 2026-03-20
- Runtime expectations reinforced:
  - Use rbenv with Ruby 3.4.3 and Bundler 2.6.9 (from `.ruby-version` and `Gemfile.lock`).
  - Initialize rbenv before running tests (see `script/preflight_test_env.sh`).
- Core character sequencing and entry workflow shipped:
  - Core order is now per fungus type via `core_character_sequences`.
  - Admin dashboard includes `Sequence Core Characters` with drag-and-drop + save.
  - Core toggle routes directly to sequential single-character entry.
  - Sequential entry actions are explicit: `Save Character` stays put; `Save & Next` advances; `Done` exits to return page/edit.
