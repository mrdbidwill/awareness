# Test Fix Plan

## Priority Fixes (Will eliminate ~80% of errors)

### 1. DnaSequence Controller Tests (8 errors)
**File:** `test/controllers/admin/dna_sequences_controller_test.rb`
**Problem:** Tests use `name` attribute but DnaSequence doesn't have it
**Actual columns:** dna_barcode_its, notes, genbank_number_url, etc.
**Fix:** Change `name: "Test"` to `notes: "Test DNA Sequence"` and `dna_barcode_its: "ATCG"`

### 2. MbList Tests (24+ errors)
**Files:**
- `test/controllers/admin/mb_lists_controller_test.rb`
- `test/requests/mb_lists_request_test.rb`
- `test/policies/mb_list_policy_test.rb`

**Problem 1:** User model doesn't have `mb_lists` association
**Problem 2:** MbListPolicy doesn't have Scope class
**Problem 3:** Routes use `admin/mb_lists` not user-scoped

**Fixes:**
- Remove user_id/user references from tests (MbList is admin-only, no user association)
- Add MbListPolicy::Scope class
- Fix routes to use admin namespace: `admin_mb_lists_path`

### 3. Route Helper Errors (30+ errors)
**Problem:** Many generated tests use non-existent route helpers
**Wrong helpers:**
- `mushroom_species_index_path` → `mushroom_species_path`
- `destroy_by_relation_mushroom_species_index_path` → custom route
- `mushroom_mr_character_mushrooms_url` → doesn't exist
- `user_url` → users don't have public URLs
- `export_pdf_mushrooms_path` → doesn't exist in routes

**Fix:** Check `rake routes` and use correct helpers

### 4. Session Method Errors (11 errors)
**Files:** Authentication controller tests
**Problem:** Tests call `session` directly but need `request.session` or controller helpers
**Fix:** Use proper session access for controller tests

### 5. Join Table User Association Errors (20 errors)
**Problem:** Tests assume `user_id` on join tables like:
- AllGroupMushroom (only has all_group_id, mushroom_id)
- ClusterMushroom (only has cluster_id, mushroom_id)
- GenusMushroom (only has genus_id, mushroom_id)

**Fix:** Don't set user_id on join tables; set it on the parent (AllGroup, Cluster, etc.)

### 6. Mocha/Stubbing Errors (13 errors)
**Problem:** Tests use `stubs`, `any_instance` (Mocha syntax) but Mocha not installed
**Files:** Various controller tests
**Fix:** Either add mocha gem OR use minitest's stub syntax OR remove stubbing

### 7. Missing Policy Scopes (3 errors)
**Files:** Need to add Scope classes to:
- MbListPolicy
- ArticlePolicy
- Others

**Fix:** Add minimal Scope class to each policy

## Automated Fix Script

Rather than manually fixing 400+ errors, let's:

1. Delete/skip the most problematic test files temporarily
2. Fix the core issues in remaining tests
3. Gradually re-enable tests as we fix fixtures

## Which Tests to Temporarily Disable

Skip these entire test files (can re-enable later):
- All integration tests (218 tests) - need complex fixtures
- All system tests (195 tests) - need Capybara setup
- All request tests (308 tests) - need better fixtures
- Performance tests (already skipped)

This leaves us with:
- Models (516 tests) ✅ These work!
- Mailers (7 tests) ✅ These work!
- Controllers (400 tests) - Fix the easy ones
- Policies (555 tests) - Fix the easy ones

## Recommendation

Let's take a pragmatic approach:
1. Keep the 500+ tests that work (models + mailers)
2. Fix the 50 easiest controller/policy test errors
3. Skip the complex integration/system/request tests for now
4. Re-enable them one file at a time as you fix fixtures

This will give you:
- ~600 passing tests immediately
- Clean test output
- Path forward to add more tests

Sound good?
