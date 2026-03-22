# Fungus Type Flexibility Refactoring

## Overview

This refactoring adds a `properties` JSON column to the `mr_characters` table, enabling type-specific metadata storage without requiring separate tables for each fungus type.

**Branch**: `feature/fungus-type-flexibility`
**Date**: November 20, 2025
**Status**: ✅ Phase 1 Complete

---

## Problem Statement

The application tracks 23+ different fungus types (Gills, Boletes, Polypores, etc.), each with potentially unique characteristics and validation rules. The initial consideration was to create separate tables for each type, but this would lead to:

- 23+ duplicate controllers, models, and views
- Complex schema changes requiring multiple migrations
- Difficulty in cross-type queries and comparisons
- Maintenance nightmare

---

## Solution: Single Table with JSON Properties

Instead of creating separate tables, we added a `properties` JSON column to store fungus_type-specific metadata. This approach provides:

✅ **Flexibility** - Each fungus type can have unique properties
✅ **Maintainability** - Single codebase, one migration
✅ **Performance** - Cached queries, minimal overhead
✅ **Scalability** - Easy to add new fungus types
✅ **Backward Compatible** - All existing code continues to work

---

## What Changed

### 1. Database Migration

**File**: `db/migrate/20251121004557_add_properties_to_mr_characters.rb`

```ruby
class AddPropertiesToMrCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :mr_characters, :properties, :json
  end
end
```

**Notes**:
- MySQL doesn't allow default values on JSON columns
- Model handles default empty hash via `after_initialize`
- MySQL JSON indexing requires generated columns (can be added later as needed)

---

### 2. Model Updates

**File**: `app/models/mr_character.rb`

Added:
- `attribute :properties, :json, default: {}` - JSON serialization
- `after_initialize :initialize_properties` - Ensures properties is never nil
- Property accessor methods for clean API

**API Methods**:

```ruby
# Get a property value
character.property(:gill_attachment_required)
# => true

# Set a property value (doesn't save automatically)
character.set_property(:gill_attachment_required, true)
character.save!

# Check if property exists
character.property?(:gill_attachment_required)
# => true

# Get all property keys
character.property_keys
# => ['gill_attachment_required', 'valid_spacings']

# Direct hash access also works
character.properties
# => {"gill_attachment_required" => true, "valid_spacings" => ["close", "crowded"]}
```

---

## Usage Examples

### Gills-Specific Properties

```ruby
gill_character = MrCharacter.find_by(name: 'gill attachment', fungus_type_id: 7)
gill_character.set_property(:gill_attachment_required, true)
gill_character.set_property(:valid_attachments, ['adnate', 'free', 'decurrent'])
gill_character.set_property(:description_template, 'Describe how gills attach to stem')
gill_character.save!
```

### Boletes-Specific Properties

```ruby
bolete_character = MrCharacter.find_by(name: 'pore surface', fungus_type_id: 2)
bolete_character.set_property(:pore_color_required, true)
bolete_character.set_property(:bruising_behavior, 'Check for color change when touched')
bolete_character.set_property(:pore_size_ranges, { small: '<1mm', medium: '1-2mm', large: '>2mm' })
bolete_character.save!
```

### Querying Properties

```ruby
# Find all characters with a specific property
MrCharacter.where("JSON_EXTRACT(properties, '$.gill_attachment_required') = true")

# For better performance with frequent queries, add a generated column:
# Migration:
# add_column :mr_characters, :has_gill_attachment_required, :boolean,
#   as: "JSON_EXTRACT(properties, '$.gill_attachment_required')", stored: true
# add_index :mr_characters, :has_gill_attachment_required
```

---

## Impact Analysis

### ✅ No Regressions

All existing functionality continues to work:

1. **Character Caching** (OPTIMIZATION_SUMMARY.md)
   - `cached_all_with_associations` still works
   - Cache expires on `updated_at` changes

2. **Comparison Feature** (COMPARISON_FEATURE.md)
   - Uses `mr_character_mushrooms` join table
   - Not affected by properties column

3. **Camera Integration** (CAMERA_INTEGRATION_COMPLETE.md)
   - Separate `image_mushrooms` table
   - No overlap with characters

4. **Performance Optimizations**
   - Counter caches unaffected
   - Lazy loading still works

### Storage Overhead

- **Empty properties**: `NULL` in MySQL (0 bytes)
- **Small properties** (1-3 keys): ~50-200 bytes
- **Large properties** (10+ keys): ~500-2000 bytes
- **Total impact**: Minimal (658 characters × avg 100 bytes = ~64KB)

---

## Testing

### Automated Test

Run the test script:

```bash
bin/rails runner test_properties.rb
```

Expected output:
```
Testing properties column:
  Character: id
  Properties initial: {}
  Properties class: Hash

Setting a property...
  After save: {"test_key" => "test_value", "gill_attachment_required" => true, ...}

  After reload: {"test_key" => "test_value", ...}
  property(:test_key) = test_value
  property(:gill_attachment_required) = true
  property?(:test_key) = true
  property_keys = ["test_key", "valid_spacings", "gill_attachment_required"]

✅ Properties column working correctly!
```

### Manual Testing

```ruby
bin/rails console

# Load a character
char = MrCharacter.find_by(fungus_type_id: 7)

# Check initial state
char.properties
# => {}

# Add some properties
char.set_property(:test, 'value')
char.set_property(:required, true)
char.save!

# Verify persistence
char.reload.properties
# => {"test" => "value", "required" => true}

# Check accessor methods
char.property(:test)        # => "value"
char.property?(:test)       # => true
char.property_keys          # => ["test", "required"]
```

---

## Next Steps (Future Phases)

### Phase 2: Type-Specific Validations (Optional)

Create validation concerns for fungus-type-specific rules:

```ruby
# app/models/concerns/fungus_type_validations.rb
module FungusTypeValidations
  extend ActiveSupport::Concern

  included do
    validate :type_specific_validations
  end

  private

  def type_specific_validations
    return unless fungus_type

    validator_class = "#{fungus_type.name.gsub(/\s+/, '')}Validator"
    validator = "FungusTypeValidators::#{validator_class}".constantize.new(self)
    validator.validate
  rescue NameError
    # No specific validator for this type
  end
end
```

### Phase 3: View Partials Per Type (Optional)

Create type-specific form sections:

```erb
<!-- app/views/admin/mr_characters/_form.html.erb -->
<% if @mr_character.fungus_type %>
  <%= render "admin/mr_characters/fungus_types/#{@mr_character.fungus_type.name.parameterize}",
             form: f, character: @mr_character %>
<% end %>
```

### Phase 4: Generated Columns for Performance (As Needed)

If querying specific properties becomes frequent:

```ruby
class AddGeneratedColumnsForProperties < ActiveRecord::Migration[8.0]
  def change
    # Add virtual column for commonly-queried property
    add_column :mr_characters, :gill_attachment_required, :boolean,
      as: "JSON_EXTRACT(properties, '$.gill_attachment_required')",
      stored: true

    add_index :mr_characters, :gill_attachment_required
  end
end
```

---

## Rollback Plan

If issues arise, rollback is simple:

```bash
# Rollback migration
bin/rails db:rollback

# Or remove the column manually
bin/rails runner "ActiveRecord::Base.connection.execute('ALTER TABLE mr_characters DROP COLUMN properties')"
```

**Note**: Properties data will be lost if rolled back. Export important properties first if needed.

---

## Benefits Over Separate Tables

| Aspect | Separate Tables (23+) | Single Table + JSON Properties |
|--------|------------------------|-------------------------------|
| **Migrations** | 23 migrations per change | 1 migration |
| **Code Duplication** | 23× controllers/models | Shared codebase + concerns |
| **Cross-Type Queries** | Complex UNIONs | Simple WHERE clauses |
| **Adding New Type** | Full scaffold needed | Just add validator/view partial |
| **Maintenance** | Very difficult | Easy |
| **Database Size** | 23 tables | 1 table |
| **Future Splitting** | Already split (hard to merge) | Easy to extract if needed |

---

## Alternative Considered: STI (Single Table Inheritance)

**Why NOT STI?**
- STI works best with 2-5 types, not 23+
- Creates sparse columns (all type-specific fields in one table)
- Schema bloat (230+ columns for 23 types × 10 fields each)
- Class explosion (23+ class files)
- Inflexible for later changes

**JSON properties** provides flexibility without the overhead.

---

## Files Modified

1. **Migration**: `db/migrate/20251121004557_add_properties_to_mr_characters.rb`
2. **Model**: `app/models/mr_character.rb`
3. **Test Script**: `test_properties.rb` (can be deleted after testing)
4. **Documentation**: This file

---

## Performance Impact

✅ **Positive**:
- No additional queries needed
- Properties loaded with character record
- Cached alongside character data
- Minimal storage overhead

⚠️ **Considerations**:
- JSON parsing has small CPU cost (negligible for small objects)
- Indexing requires generated columns (add as needed)
- Properties not directly sortable (need generated columns)

---

## Compatibility

- ✅ MySQL 5.7.8+ (JSON data type)
- ✅ MySQL 8.0+ (better JSON functions)
- ✅ Rails 8.0+ (attribute type: :json)
- ✅ Ruby 3.4+

---

## Migration Checklist

- [x] Create migration
- [x] Add properties column to mr_characters
- [x] Update MrCharacter model
- [x] Add property accessor methods
- [x] Add after_initialize callback
- [x] Run migration on development
- [x] Test property read/write
- [x] Test property persistence
- [x] Verify existing functionality
- [x] Document changes

---

## Deployment Notes

When deploying to production:

1. **Backup database first**:
   ```bash
   mysqldump -u user -p mrdbid_production > backup_before_properties.sql
   ```

2. **Run migration**:
   ```bash
   cap production deploy
   # Migration runs automatically via Capistrano
   ```

3. **Verify**:
   ```bash
   # SSH to production
   cd /opt/mrdbid/current
   RAILS_ENV=production bin/rails runner "puts MrCharacter.column_names.include?('properties')"
   # Should output: true
   ```

4. **Monitor**:
   - Check logs: `/opt/mrdbid/shared/log/production.log`
   - Verify character pages load correctly
   - Test character editing

---

## Support

If issues arise:
- Check logs: `tail -f log/development.log`
- Verify column exists: `MrCharacter.column_names`
- Test in console: `MrCharacter.first.properties`
- Review migration status: `bin/rails db:migrate:status`

---

## Conclusion

✅ **Phase 1 Complete**: Properties column added and tested
✅ **Backward Compatible**: All existing features work
✅ **Future-Proof**: Easy to extend without code duplication
✅ **Performance**: Minimal overhead, can optimize with generated columns

The foundation is now in place for fungus-type-specific metadata. Future phases can add validation logic and UI enhancements as needed, without requiring database changes.
