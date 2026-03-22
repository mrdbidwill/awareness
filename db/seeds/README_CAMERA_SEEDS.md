# Camera Equipment Seed Data

This directory contains seed data for populating camera equipment tables.

## Data Source
The camera equipment data was compiled from:
- **ExifTool database** (https://exiftool.org) - Camera make/model strings
- **Manufacturer websites** - Official product specifications
- **DPReview** (https://www.dpreview.com) - Comprehensive camera database
- **Wikipedia** - Historical and current product lists

## Data Coverage (2020-2025)

### Camera Makes (20 manufacturers)
- Canon, Nikon, Sony, Fujifilm
- Olympus, OM System, Panasonic, Leica
- Pentax, Ricoh, Hasselblad, Phase One
- Sigma, GoPro, DJI
- Apple, Samsung, Google (smartphones)
- Kodak, Minolta (legacy)

### Camera Models (~100 models)
Current popular models from 2020-2025 including:
- **DSLRs**: Canon EOS, Nikon D-series, Pentax K-series
- **Mirrorless**: Canon R, Nikon Z, Sony A-series, Fujifilm X/GFX
- **Medium Format**: Hasselblad X2D, Fujifilm GFX, Phase One
- **Smartphones**: iPhone 13-15 Pro, Samsung Galaxy S23-24, Google Pixel 8
- **Micro Four Thirds**: OM System OM-series, Panasonic Lumix G-series

### Lenses (~80 lenses)
Common lenses by mount:
- **Canon**: RF (mirrorless) and EF (DSLR) mounts
- **Nikon**: Z (mirrorless) and F (DSLR) mounts
- **Sony**: E-mount (full-frame mirrorless)
- **Fujifilm**: X-mount (APS-C), GF-mount (medium format)
- **Micro Four Thirds**: Olympus/OM System, Panasonic
- **Third-party**: Sigma, Tamron, Tokina

## Usage

### To seed the database:
```bash
rails db:seed
```

### To seed only camera equipment (if needed separately):
```ruby
# In Rails console
load Rails.root.join('db/seeds/camera_equipment_seeds.rb')
```

### To reset and reseed:
```bash
rails db:seed:replant  # Caution: truncates tables
```

## Notes

- Data uses `find_or_create_by!` so it's safe to run multiple times
- Smartphone cameras included since many users photograph mushrooms with phones
- Focus on current models (2020-2025) that users are likely to own
- Legacy manufacturers (Minolta, Kodak) included for EXIF data compatibility
- Third-party lens manufacturers (Sigma, Tamron) included for common models

## Future Updates

To add new equipment:
1. Edit `db/seeds/camera_equipment_seeds.rb`
2. Add to the appropriate `_data` array
3. Run `rails db:seed` again (won't duplicate existing records)

## Verification

After seeding, verify counts:
```ruby
# Rails console
puts "Makes: #{CameraMake.count}"
puts "Models: #{CameraModel.count}"
puts "Lenses: #{Lens.count}"
```
