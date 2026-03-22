# Mushroom Comparison Feature

## Overview

The mushroom comparison feature allows users to compare their mushrooms against all others in the database based on character traits (cap color, spore color, habitat, gill attachment, etc.).

## Architecture

### Key Components

1. **MushroomComparison Model** (`app/models/mushroom_comparison.rb`)
   - Stores pre-computed similarity scores between mushroom pairs
   - Tracks matching characters and total characters compared
   - Status: pending, completed, failed

2. **CompareMushroomsJob** (`app/jobs/compare_mushrooms_job.rb`)
   - Background job that performs comparisons asynchronously
   - Processes in batches of 100 pairs to avoid timeouts
   - Uses Jaccard similarity algorithm for scoring

3. **MushroomComparisonsController** (`app/controllers/mushroom_comparisons_controller.rb`)
   - `index`: Shows all comparisons for a mushroom
   - `show`: Shows detailed comparison between two mushrooms
   - `create`: Triggers comparison job

### Database Schema

```ruby
create_table :mushroom_comparisons do |t|
  t.references :mushroom                    # Primary mushroom
  t.references :compared_mushroom           # Mushroom being compared against
  t.integer :similarity_score              # Percentage 0-100
  t.integer :matching_characters           # Count of matching traits
  t.integer :total_characters              # Total unique traits
  t.string :status                         # pending/completed/failed
  t.datetime :completed_at
end
```

### Indexes

- `(mushroom_id, similarity_score DESC)` - Fast lookup sorted by similarity
- `(mushroom_id, compared_mushroom_id)` - Unique constraint on pairs
- `compared_mushroom_id` - Find all comparisons involving a mushroom
- `status` - Filter by completion status

## Usage

### User Workflow

1. Navigate to any mushroom detail page
2. Click the "Compare" button in the mushroom menu
3. System checks if mushroom has minimum characters (10 by default)
4. If eligible, user can click "Start Comparison"
5. Job runs in background (may take minutes for large datasets)
6. Results appear in table, sorted by similarity percentage
7. Click "Details" to see character-by-character comparison

### Running Comparisons

**Via UI:**
```
Navigate to: /mushrooms/:id/comparisons
Click: "Start Comparison" button
```

**Via Console:**
```ruby
# Compare a specific mushroom
CompareMushroomsJob.perform_later(mushroom_id)

# Or synchronously (testing only)
CompareMushroomsJob.perform_now(mushroom_id)
```

### Viewing Results

**List all comparisons for a mushroom:**
```ruby
mushroom = Mushroom.find(1)
comparisons = mushroom.mushroom_comparisons.completed.by_similarity
```

**Find high-similarity matches:**
```ruby
comparisons = MushroomComparison
  .for_mushroom(mushroom_id)
  .high_similarity(75)  # 75% or higher
  .includes(:compared_mushroom)
```

## Performance Considerations

### Optimization Strategies

1. **Batching**: Processes 100 mushroom pairs per job iteration
2. **Caching**: Results stored in database, no need to recompute
3. **Indexing**: Database indexes for fast lookups
4. **Selective Comparison**: Only compares mushrooms with 10+ characters
5. **Background Processing**: Uses Solid Queue to avoid blocking UI

### Invalidation Strategy

Comparisons are automatically invalidated when:
- A mushroom's characters are added/updated/deleted
- Triggered by `after_save` callback in `MrCharacterMushroom`
- All comparisons involving that mushroom are deleted
- User must re-run comparison to get updated results

### Scaling Considerations

For large datasets (1000+ mushrooms):
- Each mushroom compares against ~1000 others = 1000 comparisons
- At 100 pairs/batch = 10 job iterations per mushroom
- Total time depends on Solid Queue concurrency settings

**Recommendations:**
- Run overnight for full database comparisons
- Consider caching results for 24 hours
- Monitor job queue depth during peak usage
- Increase Solid Queue workers if needed

## Configuration

### Adjustable Constants

In `app/jobs/compare_mushrooms_job.rb`:

```ruby
MINIMUM_CHARACTERS = 10  # Minimum traits required
BATCH_SIZE = 100         # Pairs processed per iteration
```

### Similarity Scoring

Uses **Jaccard Similarity Index**:
```
Similarity = |A ∩ B| / |A ∪ B| × 100

Where:
  A = Set of (character_id, value) pairs for mushroom A
  B = Set of (character_id, value) pairs for mushroom B
```

**Example:**
- Mushroom A has: [(1, "red"), (2, "large"), (3, "forest")]
- Mushroom B has: [(1, "red"), (2, "small"), (4, "field")]
- Intersection: [(1, "red")] = 1 match
- Union: [(1, "red"), (2, "large"), (2, "small"), (3, "forest"), (4, "field")] = 5 total
- Similarity: 1/5 × 100 = 20%

## Testing

### Create Test Data

```bash
rails runner db/seeds/comparison_test_seeds.rb
```

This creates:
- 3 test users
- 15 mushrooms (5 per user)
- 15+ characters per mushroom
- Mix of similar and dissimilar specimens

### Manual Testing

1. Start Rails server: `rails s`
2. Login as test user: `test_user_1@example.com` / `password123`
3. Navigate to any mushroom
4. Click "Compare" button
5. Start comparison and verify results

### Automated Testing

```ruby
# Test similarity calculation
mushroom1 = Mushroom.first
mushroom2 = Mushroom.second
CompareMushroomsJob.perform_now(mushroom1.id)
comparison = MushroomComparison.find_by(mushroom: mushroom1, compared_mushroom: mushroom2)
puts "Similarity: #{comparison.similarity_score}%"
```

## Routes

```ruby
# Nested under mushroom
GET  /mushrooms/<mushroom_id>/comparisons     # Index of comparisons
POST /mushrooms/<mushroom_id>/comparisons     # Trigger comparison job

# Standalone
GET  /mushroom_comparisons/<id>               # Show detailed comparison
```

## Future Enhancements

1. **Progressive Results**: Show partial results as job progresses
2. **Weighted Scoring**: Give more weight to important characters
3. **Filters**: Filter by character type (cap, gill, spore, etc.)
4. **Export**: Export results to CSV/PDF
5. **Notifications**: Email when comparison completes
6. **Caching**: Cache results for 24 hours, auto-refresh on changes
7. **Batch Comparison**: Compare all mushrooms for a user at once

## Troubleshooting

### Comparison Not Running

1. Check Solid Queue is running: `rails solid_queue:status`
2. Check job queue: `SolidQueue::Job.where(queue_name: 'default').count`
3. Check for errors: `rails log:tail`

### Slow Performance

1. Check database indexes: `rails db:schema:dump`
2. Monitor query performance with `EXPLAIN`
3. Consider increasing `BATCH_SIZE`
4. Check Solid Queue worker count

### Stale Results

1. Comparisons invalidated when characters change
2. User must manually re-run comparison
3. Consider adding auto-recompute trigger

## Maintenance

### Cleanup Old Comparisons

```ruby
# Delete all comparisons older than 30 days
MushroomComparison.where('created_at < ?', 30.days.ago).delete_all
```

### Recompute All Comparisons

```ruby
# Queue comparison jobs for all eligible mushrooms
Mushroom.with_minimum_characters(10).find_each do |mushroom|
  CompareMushroomsJob.perform_later(mushroom.id)
end
```
