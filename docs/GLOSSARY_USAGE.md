# Wikipedia Glossary Integration

This feature automatically marks mycology terms throughout the application with definitions from Wikipedia's Glossary of Mycology.

## Features

- **Automatic term detection**: Mycology terms are automatically detected and marked with a dotted underline
- **Hover tooltips**: Quick definition preview on hover
- **Click for details**: Full definition in a modal window
- **Smart caching**: Definitions cached for 24 hours to reduce API calls
- **Wikipedia attribution**: Proper CC BY-SA 4.0 license compliance

## Usage in Views

### Basic Usage

Wrap any text content with the `mark_glossary_terms` helper:

```erb
<p><%= raw mark_glossary_terms(@mushroom.description) %></p>
```

### Options

```erb
<!-- Mark only first occurrence of each term (default) -->
<%= raw mark_glossary_terms(text, first_only: true) %>

<!-- Mark all occurrences -->
<%= raw mark_glossary_terms(text, first_only: false) %>
```

## Examples

### In a mushroom show view:

```erb
<div class="description">
  <h3>Description</h3>
  <%= raw mark_glossary_terms(@mushroom.description) %>
</div>

<div class="habitat">
  <h3>Habitat</h3>
  <%= raw mark_glossary_terms(@mushroom.habitat) %>
</div>
```

### In a character field:

```erb
<div class="character-value">
  <%= raw mark_glossary_terms(@character.value) %>
</div>
```

### In article content:

```erb
<article>
  <h1><%= @article.title %></h1>
  <div class="content">
    <%= raw mark_glossary_terms(@article.body) %>
  </div>
</article>
```

## User Experience

1. **Visual indicator**: Terms appear with a subtle dotted underline
2. **Hover**: Shows truncated definition (150 chars) in a tooltip
3. **Click**: Opens full definition in a modal with Wikipedia attribution
4. **Keyboard accessible**: Tab to term, press Enter/Space to open modal

## Technical Details

### Service: `WikipediaGlossaryService`

- Fetches glossary from Wikipedia API
- Parses HTML to extract term definitions
- Returns hash of terms and definitions
- Handles errors gracefully

### Helper: `GlossaryHelper#mark_glossary_terms`

- Marks terms with `<span class="glossary-term">` tags
- Supports first-only or all-occurrences modes
- Handles plurals automatically (term + 's')
- Uses word boundaries to avoid partial matches

### Controller: `GlossaryController`

- `GET /glossary/definition?term=basidiospore` - Returns JSON with definition
- `GET /glossary` - Browse all terms

### JavaScript: `glossary_controller.js`

- Stimulus controller attached to `<body>`
- Manages tooltips and modals
- Client-side caching of fetched definitions
- Responsive positioning

## Configuration

### Cache Duration

Modify in `app/services/wikipedia_glossary_service.rb`:

```ruby
CACHE_EXPIRY = 24.hours  # Change as needed
```

### User-Agent

Update in service if deploying:

```ruby
request['User-Agent'] = "MRDBIDApp/1.0 (your-domain.com; Educational/Research)"
```

## API Compliance

This integration follows Wikipedia API guidelines:
- Proper User-Agent identification
- Response caching (24 hours)
- Attribution in UI (CC BY-SA 4.0)
- Rate limiting via cache

## Testing

Visit `/glossary` to:
- See all available terms
- Test the tooltip/modal interaction
- Verify Wikipedia API connection

## Performance

- First load: Fetches from Wikipedia (~1-2s)
- Subsequent loads: Served from Rails cache (instant)
- Cache refresh: Every 24 hours automatically
- Client-side cache: Definitions cached per session

## Maintenance

Clear cache manually if needed:

```ruby
Rails.cache.delete("wikipedia_glossary_terms")
```

Force refresh:

```ruby
WikipediaGlossaryService.fetch_glossary_terms
```
