# Performance Optimization Plan for MRDBID

## Current Situation
- 658 MrCharacters in database
- Users need to view/edit characters frequently
- Mushroom index shows ALL mushrooms (needs pagination)
- Each mushroom edit loads massive character lists

## Optimization Strategy (Prioritized)

### ✅ COMPLETED
1. **Lazy Loading Characters** - Only load when user clicks "Load all available characters"
2. **Database Indexes** - All critical indexes are in place
3. **Eager Loading** - Fixed N+1 queries for trees, plants, genera, species

---

### 🔥 HIGH PRIORITY (Implement Next)

#### 1. **Fragment Caching for MrCharacters**
**Impact**: HUGE - Cache once, serve instantly to all users
**Complexity**: Low

The list of all 658 characters rarely changes. Cache it:

```ruby
# config/environments/development.rb & production.rb
config.action_controller.perform_caching = true

# app/models/mr_character.rb
class MrCharacter < ApplicationRecord
  after_save :expire_character_cache
  after_destroy :expire_character_cache

  def self.cached_all_with_associations
    Rails.cache.fetch(['mr_characters', 'all', maximum(:updated_at)]) do
      includes(:part, :display_option, :source_data)
        .order('parts.name ASC, mr_characters.name ASC')
        .to_a
    end
  end

  private
  def expire_character_cache
    Rails.cache.delete_matched('mr_characters/all/*')
  end
end

# In views, replace:
# MrCharacter.includes(...).order(...)
# With:
# MrCharacter.cached_all_with_associations
```

**Benefit**: First load takes ~500ms, subsequent loads take ~5ms

---

#### 2. **Pagination for Mushrooms Index**
**Impact**: HIGH - Currently loads ALL mushrooms
**Complexity**: Already done! (You have Kaminari)

You already have `page(params[:page]).per(5)` at line 21 of mushrooms_controller.rb
**Issue**: Per-page is only 5. Increase to 25-50 for better UX:

```ruby
.page(params[:page]).per(25)  # or .per(50)
```

---

#### 3. **Database Connection Pooling**
**Impact**: MEDIUM - Prevents slowdown under load
**Complexity**: Low

```yaml
# config/database.yml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 20 } %>
  checkout_timeout: 5
```

---

#### 4. **Counter Caches**
**Impact**: MEDIUM - Speeds up counts (e.g., mushroom.trees.count)
**Complexity**: Medium

```ruby
# Migration
rails g migration AddCounterCachesToMushrooms trees_count:integer plants_count:integer

# In migration:
def change
  add_column :mushrooms, :trees_count, :integer, default: 0
  add_column :mushrooms, :plants_count, :integer, default: 0
  add_column :mushrooms, :mr_characters_count, :integer, default: 0

  # Reset counters for existing records
  reversible do |dir|
    dir.up do
      Mushroom.find_each do |mushroom|
        Mushroom.reset_counters(mushroom.id, :trees, :plants, :mr_character_mushrooms)
      end
    end
  end
end

# Update models:
class MushroomTree < ApplicationRecord
  belongs_to :mushroom, counter_cache: :trees_count
  belongs_to :tree
end

class MushroomPlant < ApplicationRecord
  belongs_to :mushroom, counter_cache: :plants_count
  belongs_to :plant
end
```

Then in views: `@mushroom.trees_count` (instant) vs `@mushroom.trees.count` (queries DB)

---

### ⚡ MEDIUM PRIORITY

#### 5. **Turbo Frame for Character Sections**
**Impact**: MEDIUM - Loads character sections on-demand
**Complexity**: Medium

Instead of loading all characters in the edit page, load them via Turbo Frame:

```erb
<!-- In edit.html.erb -->
<%= turbo_frame_tag "available_characters" do %>
  <div class="bg-blue-50 border border-blue-200 rounded-md p-4 mb-3">
    <p class="text-sm text-gray-700 mb-2">To improve page load speed, available characters load on demand.</p>
    <%= link_to "Load available characters",
                mushroom_available_characters_path(@mushroom),
                data: { turbo_frame: "available_characters" },
                class: "rounded-md px-3 py-1.5 bg-blue-600 hover:bg-blue-500 text-white inline-block font-medium text-sm" %>
  </div>
<% end %>

# New controller action:
def available_characters
  @mushroom = Mushroom.find(params[:id])
  @all_chars = MrCharacter.cached_all_with_associations
  # ... render partial with character lists
end
```

---

#### 6. **Stimulus Reflex or Hotwire for Real-time Updates**
**Impact**: MEDIUM - Better UX, feels faster
**Complexity**: Medium

Already using Turbo! Ensure all forms use `data: { turbo: true }`

---

#### 7. **Background Jobs for Heavy Operations**
**Impact**: LOW (not needed yet)
**Complexity**: Medium

If you add export/import features, use Sidekiq:
```ruby
# For later, when needed
gem 'sidekiq'
```

---

### 🔧 LOW PRIORITY (Nice to Have)

#### 8. **HTTP/2 and Asset Optimization**
- Enable HTTP/2 on server (nginx/puma)
- Use WebP images instead of JPEG (already doing for colors!)
- CDN for static assets (CloudFront, Cloudflare)

#### 9. **Database Read Replicas**
- If serving 1000+ concurrent users
- Send reads to replica, writes to primary

#### 10. **Full-Text Search**
- If users search mushrooms frequently
- Use pg_search gem with PostgreSQL full-text search

```ruby
gem 'pg_search'

class Mushroom < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_name_and_description,
    against: [:name, :description, :comments],
    using: { tsearch: { prefix: true } }
end

# Usage:
Mushroom.search_by_name_and_description("agaricus")
```

---

## Implementation Order

### Week 1: Quick Wins
1. ✅ Lazy load characters (DONE)
2. Add fragment caching for MrCharacter lists
3. Increase mushroom pagination to 25-50 per page
4. Add counter caches

### Week 2: Architecture
5. Convert character loading to Turbo Frames
6. Database connection pooling in production

### Week 3+: Advanced
7. Monitor performance with tools (Bullet gem, rack-mini-profiler)
8. Add full-text search if needed
9. Consider read replicas for high traffic

---

## Monitoring Tools (Install These)

```ruby
# Gemfile
group :development do
  gem 'bullet'                  # Detects N+1 queries
  gem 'rack-mini-profiler'      # Shows page load breakdown
  gem 'memory_profiler'         # Memory usage
end

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.rails_logger = true
  Bullet.add_footer = true
end
```

---

## Performance Targets

- **Mushroom Index**: < 200ms (currently varies)
- **Mushroom Show**: < 300ms
- **Mushroom Edit (without chars)**: < 300ms
- **Mushroom Edit (with chars)**: < 800ms (acceptable for opt-in load)
- **Autocomplete Response**: < 100ms (already achieved)

---

## Questions to Consider

1. **How often do MrCharacters change?**
   - If rarely: Fragment caching is PERFECT
   - If daily: Still use caching with 24hr expiry

2. **How many concurrent users?**
   - < 10: Current setup is fine
   - 10-100: Add fragment caching + counter caches
   - 100+: Add read replicas + CDN

3. **What's the slowest page?**
   - Run `bin/rails runner "puts Benchmark.measure { MushroomsController.new.edit }"` to find bottlenecks

---

## Cost-Benefit Analysis

| Optimization | Dev Time | Impact | Recommendation |
|--------------|----------|--------|----------------|
| Fragment Caching | 2 hours | 🔥🔥🔥 | **DO NOW** |
| Counter Caches | 1 hour | 🔥🔥 | **DO NOW** |
| Pagination Increase | 5 min | 🔥 | **DO NOW** |
| Turbo Frames | 4 hours | 🔥🔥 | Week 2 |
| Full-text Search | 6 hours | 🔥 | Only if needed |
| Read Replicas | 8 hours | 🔥 | Only for 100+ users |

---

## Next Steps

1. **Implement fragment caching for MrCharacter** (biggest bang for buck)
2. **Add counter caches** (simple, high value)
3. **Install monitoring tools** (Bullet, rack-mini-profiler)
4. **Measure before/after** each optimization

Would you like me to implement any of these now?
