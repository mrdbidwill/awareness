# Glossary Integration Summary

## Views Updated with Glossary Term Marking

The `mark_glossary_terms` helper has been integrated into the following views to automatically highlight mycology terms:

### 1. **Mushroom Display** (`app/views/mushrooms/_mushroom.html.erb`)

Marked fields:
- `mushroom.description` - Full specimen description
- `mushroom.comments` - User comments about the specimen
- `mushroom.personal_notes` - Private notes (visible only to owner)

Location: Lines 69, 76, 83

### 2. **Mushroom Show Page** (`app/views/mushrooms/show.html.erb`)

Marked fields:
- `lookup_item.description` - Character lookup item descriptions (e.g., gill attachment types, cap shapes)

Location: Line 148

Example: When displaying character values like "adnate gills" or "convex cap", the description text will have glossary terms highlighted.

### 3. **Articles** (`app/views/articles/show.html.erb`)

Marked fields:
- `@article.body` - Full article content (both HTML and plain text formats)

Location: Lines 20-24

### 4. **Admin Characters** (`app/views/admin/mr_characters/_mr_character.html.erb`)

Marked fields:
- `mr_character.description` - Character definition/description
- `mr_character.comments` - Internal comments about the character

Location: Lines 12, 15

## Example Usage Patterns

### Basic Field Display
```erb
<%= raw mark_glossary_terms(@mushroom.description) %>
```

### With Sanitization (for HTML content)
```erb
<%= raw mark_glossary_terms(sanitize(@article.body, tags: [...], attributes: [...])) %>
```

### With Simple Format (for plain text)
```erb
<%= raw mark_glossary_terms(simple_format(@article.body)) %>
```

### With Presence Check
```erb
<% if (desc = mr_character.description.presence) %>
  <%= raw mark_glossary_terms(desc) %>
<% end %>
```

## What Gets Marked

Currently, 421 mycology terms from Wikipedia's Glossary of Mycology are automatically detected and marked, including:

- Anatomical terms: basidiospore, basidium, cap, stem, hymenium
- Morphological terms: adnate, decurrent, convex, umbonate
- Ecological terms: mycorrhizal, saprobic, parasitic
- Descriptive terms: glabrous, tomentose, viscid, hygrophanous
- And many more...

## User Experience

When viewing any of these fields:

1. **Visual cue**: Glossary terms appear with dotted underline
2. **Hover**: Quick definition appears in tooltip (~150 chars)
3. **Click**: Full definition opens in modal with Wikipedia attribution
4. **First occurrence**: By default, only the first occurrence of each term per field is marked (reduces visual clutter)

## Adding Glossary to New Views

To add glossary support to any text field:

```erb
<!-- In your view file -->
<div class="description">
  <%= raw mark_glossary_terms(@model.field_name) %>
</div>
```

### Options

```erb
<!-- Mark all occurrences (instead of just first) -->
<%= raw mark_glossary_terms(text, first_only: false) %>

<!-- Default behavior (first only) -->
<%= raw mark_glossary_terms(text, first_only: true) %>
```

## Performance Notes

- First load per server restart: ~1-2 seconds (fetches from Wikipedia)
- Subsequent loads: Instant (served from Rails cache)
- Cache duration: 24 hours
- Terms are matched using regex with word boundaries to avoid false matches
- Plurals are automatically handled (e.g., "basidiospore" matches "basidiospores")

## Fields NOT Marked (By Design)

Glossary marking is **not** applied to:

- Form inputs (edit/new views) - Users need to edit plain text
- Navigation elements
- Labels and field names
- Admin-only metadata
- Structured data (JSON, IDs, timestamps)

## Testing the Integration

1. Visit any mushroom show page with a description containing terms like "basidiospore", "cap", or "gills"
2. Visit `/glossary` to browse all available terms
3. Check articles with mycology content
4. View admin character definitions

## Maintenance

To clear the glossary cache manually:
```ruby
Rails.cache.delete("wikipedia_glossary_terms")
```

To force a fresh fetch from Wikipedia:
```ruby
WikipediaGlossaryService.fetch_glossary_terms
```
