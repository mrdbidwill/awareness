# Camera Equipment Database - Summary

## Successfully Seeded! ✅

Your database has been populated with current camera equipment data (2020-2025).

### Database Contents:

- **20 Camera Makes** (manufacturers)
- **63 Camera Models** (specific cameras)
- **53 Lenses** (common lenses by mount/manufacturer)

### Data Sources:
- ExifTool database (https://exiftool.org)
- Manufacturer official websites
- DPReview product database
- Wikipedia product lists

## Camera Makes Included:

Major manufacturers:
- Canon, Nikon, Sony (market leaders)
- Fujifilm, Olympus/OM System
- Panasonic, Leica, Pentax/Ricoh
- Hasselblad, Phase One (medium format)
- Sigma (cameras and lenses)
- Apple, Samsung, Google (smartphones)
- Legacy: Kodak, Minolta

## Camera Models Coverage:

### DSLRs:
- Canon: EOS 5D Mark IV, 6D Mark II, 90D, Rebel T7
- Nikon: D850, D780, D7500
- Pentax: K-3 Mark III

### Mirrorless (Full-Frame):
- **Canon RF**: R5, R6, R6 Mark II, R3
- **Nikon Z**: Z9, Z8, Z6 III, Z7 II, Z5
- **Sony A**: A1, A7R V, A7 IV, A7S III, A9 III
- **Panasonic Lumix S**: S5 II, S5 IIX, S1H
- **Leica**: M11, Q3, SL3

### Mirrorless (APS-C):
- **Canon**: R7, R10, R50
- **Nikon**: Z fc, Z50
- **Sony**: A6700, A6400, ZV-E10
- **Fujifilm X**: X-H2S, X-H2, X-T5, X-T4, X-S20

### Medium Format:
- **Fujifilm GFX**: GFX100 II, GFX100S, GFX50S II
- **Hasselblad**: X2D 100C, 907X 50C

### Micro Four Thirds:
- **OM System**: OM-1, OM-5
- **Olympus**: E-M1 Mark III, E-M5 Mark III
- **Panasonic**: GH6, GH5, G9

### Smartphones:
- **Apple**: iPhone 15 Pro Max, 14 Pro, 13 Pro
- **Samsung**: Galaxy S24 Ultra, S23 Ultra
- **Google**: Pixel 8 Pro

## Lenses Included (~53 lenses):

### Canon:
- RF mount (mirrorless): 24-70mm f/2.8, 70-200mm f/2.8, 50mm f/1.8, 85mm f/1.2, 100-500mm
- EF mount (DSLR): 24-70mm f/2.8 II, 70-200mm f/2.8 IS III, 100mm f/2.8L Macro

### Nikon:
- Z mount (mirrorless): 24-70mm f/2.8 S, 70-200mm f/2.8 VR S, 50mm f/1.8 S, MC 105mm f/2.8 Macro
- F mount (DSLR): AF-S 24-70mm f/2.8E VR, 70-200mm f/2.8E FL

### Sony E-mount:
- FE 24-70mm f/2.8 GM II, FE 70-200mm f/2.8 GM OSS II, FE 90mm f/2.8 Macro, FE 200-600mm

### Fujifilm X-mount:
- XF 16-55mm f/2.8, XF 50-140mm f/2.8, XF 80mm f/2.8 Macro, XF 150-600mm

### Olympus/OM System (MFT):
- M.Zuiko 12-40mm f/2.8 PRO, 40-150mm f/2.8 PRO, 60mm f/2.8 Macro, 90mm f/3.5 Macro IS PRO

### Third-Party:
- **Sigma**: 24-70mm f/2.8 DG DN Art, 85mm f/1.4 DG DN Art, 105mm f/2.8 Macro
- **Tamron**: 28-75mm f/2.8 Di III VXD G2, 35-150mm f/2-2.8, 90mm f/2.8 Di III Macro
- **Tokina**: atx-m 85mm f/1.8 FE

## Files Created:

1. **db/seeds/camera_equipment_seeds.rb** - Main seed file
2. **db/seeds/README_CAMERA_SEEDS.md** - Documentation
3. **app/models/camera_make.rb** - CameraMake model
4. **app/models/camera_model.rb** - CameraModel model
5. **app/models/camera.rb** - Camera model
6. **app/models/lens.rb** - Lens model (updated)

## Database Tables:

### camera_makes
- id, name, description, comments, timestamps

### camera_models
- id, name, description, comments, timestamps

### cameras
- id, name, description, comments, camera_make_id, camera_model_id, timestamps

### lenses
- id, make, model, description, comments, timestamps

## Usage:

The seed data is idempotent (safe to run multiple times). Running `rails db:seed` again will NOT create duplicates.

To verify:
```bash
rails console
```

```ruby
puts "Camera Makes: #{CameraMake.count}"
puts "Camera Models: #{CameraModel.count}"
puts "Lenses: #{Lens.count}"

# View some examples
CameraMake.first(5).pluck(:name)
# => ["Canon", "Nikon", "Sony", "Fujifilm", "Olympus"]

CameraModel.where("name LIKE ?", "%R5%").pluck(:name)
# => ["EOS R5"]

Lens.where(make: "Canon").first(3).pluck(:model)
# => ["RF 24-70mm f/2.8L IS USM", "RF 70-200mm f/2.8L IS USM", ...]
```

## Next Steps:

Now that the equipment database is populated, you can:

1. **Connect to image_mushrooms**: Update image_mushrooms to reference these tables instead of storing strings
2. **Add admin interfaces**: Create forms to manage equipment in admin panel
3. **Expand data**: Add more models/lenses as needed
4. **User selection**: Create dropdowns for users to select their equipment

## Notes:

- Focus on 2020-2025 models (current equipment)
- Smartphone cameras included (many users photograph mushrooms with phones)
- Third-party lens manufacturers included (Sigma, Tamron, Tokina)
- Data can be easily updated by editing the seed file and running `rails db:seed` again
