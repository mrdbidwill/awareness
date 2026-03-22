# Testing Quick Start Guide

## Running Tests

### Run All Tests
```bash
rails test
```

### Run Tests by Category
```bash
# Models
rails test test/models/

# Controllers
rails test test/controllers/

# Policies
rails test test/policies/

# Mailers
rails test test/mailers/

# Integration (user flows)
rails test test/integration/

# System (UI/browser tests)
rails test:system

# Request (API tests)
rails test test/requests/

# Performance
rails test test/performance/
```

### Run Specific Test File
```bash
rails test test/controllers/mushrooms_controller_test.rb
```

### Run Specific Test
```bash
rails test test/controllers/mushrooms_controller_test.rb:25
```

## Code Coverage

### View Coverage Report
```bash
rails test
open coverage/index.html
```

Current targets:
- Line coverage: 50% (target 80%)
- Branch coverage: 40% (target 60%)

## Performance Testing

### Check for N+1 Queries
```bash
rails test test/performance/n_plus_one_test.rb
```

### Verify Database Indexes
```bash
rails test test/performance/database_indexing_test.rb
```

### Query Performance Benchmarks
```bash
rails test test/performance/query_performance_test.rb
```

## Mutation Testing

Test the quality of your tests:
```bash
bundle exec mutant run --config config/mutant.yml
```

## CI/CD

CI/CD is intentionally disabled; GitHub Actions workflow files were removed due to noisy false errors.
Run tests locally before deployments.

## Test Statistics

- **207 test files**
- **2,136 test cases**
- **4,280 assertions**
- **Target: 80% code coverage**

### Coverage by Category
- Current (2026-03-14): 80.75% line coverage, 56.29% branch coverage
- Detailed breakdown: review `coverage/index.html`

## Common Commands

```bash
# Run with verbose output
rails test -v

# Run specific pattern
rails test test/controllers/admin/*_test.rb

# Run with seed for reproducibility
rails test --seed=12345

# Run failing tests only
rails test --fail-fast
```

## Documentation

- `TEST_COVERAGE_PLAN.md` - Original gap analysis
- `TEST_SUITE_COMPLETE_SUMMARY.md` - Complete refactoring summary
- `TESTING_QUICK_START.md` - This file

## Troubleshooting

### Tests timing out?
Reduce parallel workers in `test/test_helper.rb`:
```ruby
parallelize(workers: 1)
```

### Coverage too strict?
Adjust thresholds in `test/test_helper.rb`:
```ruby
minimum_coverage line: 50, branch: 40
```

### N+1 queries detected?
Check `test/performance/n_plus_one_test.rb` for eager loading examples.

## Next Steps

1. Run `rails test` to verify all tests pass
2. Review `coverage/index.html` for gaps
3. Add fixtures/factories as needed
4. Gradually increase coverage targets
5. Expand system tests as new UI flows ship

Happy testing! 🧪
