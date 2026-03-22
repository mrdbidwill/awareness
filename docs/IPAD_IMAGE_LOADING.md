# iPad / Safari Image Loading Standard

**Related Standard:** `PROJECT_MEMORY.md` (Authorization & Ownership Rules)

## Critical Rule: NEVER Use loading="lazy" for Mushroom Images

**Date:** 2026-01-04
**Status:** MANDATORY - All image views MUST use eager loading

## The Problem

Safari on iPad has a known bug where `loading="lazy"` images don't load properly when navigating via Turbo/client-side routing. Instead of loading the images, Safari displays the default broken image icon (blue square with question mark).

**This has been fixed TWICE:**
1. **2026-01-01** (commit 62d085b) - Fixed mushrooms/index.html.erb
2. **2026-01-04** (commit 4a6d2ac) - Fixed 4 remaining views

## The Solution: Always Use Eager Loading

```erb
<%# ✅ CORRECT - USE THIS PATTERN %>
<%= image_tag(
      url_for(image.variant(...)),
      loading: "eager",
      decoding: "async",
      fetchpriority: "high",
      alt: "..."
    ) %>

<%# ❌ WRONG - NEVER USE THIS %>
<%= image_tag(
      url_for(image.variant(...)),
      loading: "lazy",
      decoding: "async",
      fetchpriority: "low",
      alt: "..."
    ) %>
```

## Why Eager Loading is Correct for This Application

1. **Primary Content**: Mushroom images are the main content, not decorative
2. **Small Grid**: Typically showing 3-12 images per page, not hundreds
3. **Above the Fold**: Images are visible immediately, not way down the page
4. **Safari Compatibility**: Works reliably across all browsers including Safari on iPad
5. **Turbo Navigation**: Eager loading works correctly with Turbo Drive navigation

## Views That Must Use Eager Loading

All views displaying mushroom images:

1. ✅ `app/views/mushrooms/index.html.erb` - Your Mushrooms grid
2. ✅ `app/views/mushrooms/show.html.erb` - Individual mushroom detail page ("Back to Mushroom")
3. ✅ `app/views/mushrooms/edit.html.erb` - Edit page image thumbnails
4. ✅ `app/views/mushroom_search/index.html.erb` - Search results
5. ✅ `app/views/shared/_image_grid.html.erb` - Reusable image grid partial
6. ✅ `app/views/shared/_image_card.html.erb` - Reusable image card partial
7. ✅ Any other views displaying mushroom images

## Standard Pattern for Image Display

### Full Pattern (with WebP optimization)

```erb
<picture>
  <%= tag.source(
        srcset: url_for(
          image_mushroom.image_file.variant(
            resize_to_fill: [200, 200],
            format: :webp,
            saver: { strip: true, quality: 60, effort: 4 }
          ).processed
        ),
        type: "image/webp"
      ) %>
  <%= image_tag(
        image_mushroom.image_file.variant(
          resize_to_fill: [200, 200],
          saver: { strip: true, quality: 72, optimize_coding: true }
        ).processed,
        width: 200,
        height: 200,
        class: "w-full h-full object-cover block",
        loading: "eager",
        decoding: "async",
        fetchpriority: "high",
        alt: image_mushroom.image_name.presence || @mushroom.name
      ) %>
</picture>
```

### Simple Pattern (WebP only)

```erb
<%= image_tag(
      url_for(image_mushroom.image_file.variant(
        resize_to_fill: [120, 120],
        format: :webp,
        saver: { strip: true, quality: 60, effort: 4 }
      )),
      alt: "Mushroom image",
      loading: "eager",
      class: "w-full h-full object-cover"
    ) %>
```

## When Lazy Loading IS Appropriate

Lazy loading is appropriate for:
- Hero images way down a very long page
- Hundreds of images in a long scrolling list
- Images that are definitely below the fold
- Decorative images that aren't critical content

**In this application, there are NO such cases.** All mushroom images should use eager loading.

## Testing on iPad

To verify the fix works:

1. Open Safari on iPad
2. Navigate to Your Mushrooms page
3. Click on a mushroom to view details
4. Click "Back to Mushroom" or navigate to edit page
5. **All images should load immediately, no blue squares**

## Automated Check

Run this command to verify no lazy loading remains:

```bash
grep -r 'loading: "lazy"' app/views/
```

This should return NO results. If it returns any files, those files need to be fixed.

## Checklist for New Image Views

When creating a new view with images:

- [ ] Use `loading: "eager"` not `loading: "lazy"`
- [ ] Use `fetchpriority: "high"` not `fetchpriority: "low"`
- [ ] Include proper `alt` text
- [ ] Use `decoding: "async"` for better performance
- [ ] Test on iPad Safari before deploying

## Why This Keeps Breaking

This pattern has broken twice because:

1. **Cargo cult code** - Copying `loading: "lazy"` from online examples without understanding the implications
2. **Performance misconceptions** - Assuming lazy loading is always better for performance
3. **Lack of iPad testing** - Not testing on Safari/iPad where the bug manifests
4. **Missing documentation** - No clear standard documented (until now)

## References

- Safari lazy loading bug: https://bugs.webkit.org/show_bug.cgi?id=200764
- MDN loading attribute: https://developer.mozilla.org/en-US/docs/Web/Performance/Lazy_loading
- Turbo and lazy loading: https://github.com/hotwired/turbo/issues/28

## History

- **2026-01-01** - First fix (commit 62d085b): Changed mushrooms/index.html.erb from lazy to eager
- **2026-01-04** - Complete fix (commit 4a6d2ac): Changed 4 remaining views from lazy to eager
- **2026-01-04** - Documentation created to prevent future regressions

**If you're tempted to add loading="lazy" to any mushroom image, DON'T. Read this document first.**
