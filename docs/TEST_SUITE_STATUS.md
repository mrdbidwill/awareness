# Test Suite Status

**Branch:** `main`
**Last Updated:** 2026-03-14
**Status:** ✅ Full suite passing (manual runs)

## Current Test Results

- **Latest run:** 2136 runs, 4280 assertions
- **Failures/Errors/Skips:** 0 / 0 / 0
- **Coverage:** 80.75% line, 56.29% branch (SimpleCov)
- **Runtime:** ~23s locally (includes system tests)
- **CI/CD:** Disabled intentionally; manual test runs only

## Known Configuration Changes

### 1. Parallel Testing Disabled
- **Why:** DRb connection issues with parallel workers
- **Location:** `test/test_helper.rb`
- **Can be re-enabled:** After verifying test isolation
- **Impact:** Tests run sequentially (slower but stable)

### 2. SimpleCov Coverage Thresholds
- **Current:** Line 50%, Branch 40%
- **Target:** Line 80%, Branch 60%
- **Location:** `test/test_helper.rb`
- **Note:** Line target met; branch target still in progress

### 3. Devise Mailer Tests Simplified
- **Why:** Avoid Devise mapping configuration complexity
- **What:** Tests password reset instead of all Devise methods
- **Can be expanded:** When Devise test configuration is refined

## Test Categories Status

| Category | Files | Status | Notes |
|----------|-------|--------|-------|
| Models | 48 | ✅ Pass | Full suite green |
| Mailers | 2 | ✅ Pass | Contact mailer + simplified Devise |
| Policies | 39 | ✅ Pass | Authorization coverage green |
| Controllers | 65 | ✅ Pass | Full suite green |
| Integration | 11 | ✅ Pass | Production boot + auth flows |
| System | 13 | ✅ Pass | Selenium/Capybara UI coverage |
| Requests | 13 | ✅ Pass | API coverage green |
| Performance | 3 | ✅ Pass | N+1 + indexing checks |
| Jobs | 4 | ✅ Pass | Export jobs covered |
| Services | 5 | ✅ Pass | PDF + color extraction + exporter covered |
| Queries | 2 | ✅ Pass | Sorting/comparison queries covered |

## How to Run Tests

### Run subset (fast)
```bash
rails test test/models/ test/mailers/
```

### Run full suite
```bash
rails test
```

### Run with coverage
```bash
rails test
open coverage/index.html
```

## Coverage Goals

- **Current:** 80.75% line, 56.29% branch
- **Target:** 80% line, 60% branch

## Issues & Workarounds

### DRb Connection Issues
**Problem:** Parallel testing causes "Bad file descriptor" errors
**Workaround:** Disabled parallel testing
**Solution:** Investigate test isolation issues before re-enabling

## Documentation

- `TEST_COVERAGE_PLAN.md` - Original gap analysis
- `TEST_SUITE_COMPLETE_SUMMARY.md` - Comprehensive details
- `TESTING_QUICK_START.md` - Quick reference guide
- `TEST_SUITE_STATUS.md` - This file (current status)
