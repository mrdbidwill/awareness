# Camera Equipment Seed Data
# This file contains current camera makes, models, and lenses (2020-2025)
# Data compiled from ExifTool, manufacturer websites, and DPReview

puts "Seeding camera equipment data..."

# ============================================================================
# CAMERA MAKES
# ============================================================================
puts "Creating camera makes..."

camera_makes_data = [
  { name: "Canon", description: "Japanese multinational corporation specializing in imaging and optical products" },
  { name: "Nikon", description: "Japanese multinational corporation specializing in optics and imaging products" },
  { name: "Sony", description: "Japanese multinational conglomerate, leader in mirrorless camera technology" },
  { name: "Fujifilm", description: "Japanese multinational photography and imaging company" },
  { name: "Olympus", description: "Japanese manufacturer of optics and reprography products (now OM System)" },
  { name: "OM System", description: "Successor brand to Olympus imaging division" },
  { name: "Panasonic", description: "Japanese multinational electronics corporation, known for Lumix cameras" },
  { name: "Leica", description: "German company specializing in premium cameras and lenses" },
  { name: "Pentax", description: "Japanese camera brand owned by Ricoh" },
  { name: "Ricoh", description: "Japanese imaging and electronics company" },
  { name: "Hasselblad", description: "Swedish manufacturer of medium format cameras" },
  { name: "Phase One", description: "Danish manufacturer of high-end medium format cameras" },
  { name: "Sigma", description: "Japanese company producing cameras, lenses and flashes" },
  { name: "GoPro", description: "American action camera manufacturer" },
  { name: "DJI", description: "Chinese technology company, known for drones and cameras" },
  { name: "Apple", description: "American technology company (iPhone cameras)" },
  { name: "Samsung", description: "South Korean multinational (smartphone cameras)" },
  { name: "Google", description: "American technology company (Pixel phones)" },
  { name: "Kodak", description: "American photographic film and camera company" },
  { name: "Minolta", description: "Japanese camera manufacturer (acquired by Sony/Konica)" }
]

camera_makes = {}
camera_makes_data.each do |make_data|
  camera_makes[make_data[:name]] = CameraMake.find_or_create_by!(name: make_data[:name]) do |make|
    make.description = make_data[:description]
  end
end

puts "Created #{camera_makes.count} camera makes"

# ============================================================================
# CAMERA MODELS - Organized by manufacturer
# ============================================================================
puts "Creating camera models..."

camera_models_data = [
  # Canon Models (Popular DSLRs and Mirrorless 2020-2025)
  { make: "Canon", name: "EOS R5", description: "Full-frame mirrorless, 45MP, 8K video" },
  { make: "Canon", name: "EOS R6", description: "Full-frame mirrorless, 20MP, excellent low-light" },
  { make: "Canon", name: "EOS R6 Mark II", description: "Full-frame mirrorless, 24MP, improved AF" },
  { make: "Canon", name: "EOS R3", description: "Full-frame mirrorless sports camera, 24MP" },
  { make: "Canon", name: "EOS R7", description: "APS-C mirrorless, 32.5MP, wildlife photography" },
  { make: "Canon", name: "EOS R10", description: "APS-C mirrorless, 24MP, entry-level" },
  { make: "Canon", name: "EOS R50", description: "APS-C mirrorless, 24MP, compact" },
  { make: "Canon", name: "EOS 5D Mark IV", description: "Full-frame DSLR, 30.4MP" },
  { make: "Canon", name: "EOS 6D Mark II", description: "Full-frame DSLR, 26.2MP" },
  { make: "Canon", name: "EOS 90D", description: "APS-C DSLR, 32.5MP" },
  { make: "Canon", name: "EOS Rebel T7", description: "Entry-level APS-C DSLR, 24.1MP" },

  # Nikon Models (Popular DSLRs and Mirrorless 2020-2025)
  { make: "Nikon", name: "Z9", description: "Flagship full-frame mirrorless, 45.7MP, 8K video" },
  { make: "Nikon", name: "Z8", description: "Full-frame mirrorless, 45.7MP, compact Z9" },
  { make: "Nikon", name: "Z6 II", description: "Full-frame mirrorless, 24.5MP, dual processors" },
  { make: "Nikon", name: "Z6 III", description: "Full-frame mirrorless, 24.5MP, partially stacked sensor" },
  { make: "Nikon", name: "Z7 II", description: "Full-frame mirrorless, 45.7MP, high resolution" },
  { make: "Nikon", name: "Z5", description: "Full-frame mirrorless, 24MP, entry-level" },
  { make: "Nikon", name: "Z fc", description: "APS-C mirrorless, 20.9MP, retro design" },
  { make: "Nikon", name: "Z50", description: "APS-C mirrorless, 20.9MP" },
  { make: "Nikon", name: "D850", description: "Full-frame DSLR, 45.7MP, workhorse" },
  { make: "Nikon", name: "D780", description: "Full-frame DSLR, 24.5MP, hybrid AF" },
  { make: "Nikon", name: "D7500", description: "APS-C DSLR, 20.9MP" },

  # Sony Models (Mirrorless leaders 2020-2025)
  { make: "Sony", name: "A1", description: "Flagship full-frame mirrorless, 50.1MP, 8K video" },
  { make: "Sony", name: "A7R V", description: "Full-frame mirrorless, 61MP, AI-powered AF" },
  { make: "Sony", name: "A7 IV", description: "Full-frame mirrorless, 33MP, all-rounder" },
  { make: "Sony", name: "A7C", description: "Full-frame mirrorless, 24MP, compact" },
  { make: "Sony", name: "A7S III", description: "Full-frame mirrorless, 12MP, video-centric" },
  { make: "Sony", name: "A9 III", description: "Full-frame mirrorless, 24.6MP, global shutter" },
  { make: "Sony", name: "A6700", description: "APS-C mirrorless, 26MP, AI processing" },
  { make: "Sony", name: "A6400", description: "APS-C mirrorless, 24.2MP, popular" },
  { make: "Sony", name: "ZV-E10", description: "APS-C mirrorless, 24MP, vlogging camera" },

  # Fujifilm Models (X-Series and GFX 2020-2025)
  { make: "Fujifilm", name: "X-H2S", description: "APS-C mirrorless, 26.1MP, stacked sensor" },
  { make: "Fujifilm", name: "X-H2", description: "APS-C mirrorless, 40.2MP, high resolution" },
  { make: "Fujifilm", name: "X-T5", description: "APS-C mirrorless, 40.2MP, rangefinder style" },
  { make: "Fujifilm", name: "X-T4", description: "APS-C mirrorless, 26.1MP, IBIS" },
  { make: "Fujifilm", name: "X-S20", description: "APS-C mirrorless, 26.1MP, video-focused" },
  { make: "Fujifilm", name: "X-E4", description: "APS-C mirrorless, 26.1MP, compact rangefinder" },
  { make: "Fujifilm", name: "GFX100 II", description: "Medium format, 102MP, flagship" },
  { make: "Fujifilm", name: "GFX100S", description: "Medium format, 102MP, more affordable" },
  { make: "Fujifilm", name: "GFX50S II", description: "Medium format, 51.4MP" },

  # Olympus/OM System (Micro Four Thirds)
  { make: "OM System", name: "OM-1", description: "Micro Four Thirds, 20MP, flagship" },
  { make: "OM System", name: "OM-5", description: "Micro Four Thirds, 20MP, compact" },
  { make: "Olympus", name: "E-M1 Mark III", description: "Micro Four Thirds, 20.4MP" },
  { make: "Olympus", name: "E-M5 Mark III", description: "Micro Four Thirds, 20.4MP" },

  # Panasonic (Lumix series)
  { make: "Panasonic", name: "Lumix S5 II", description: "Full-frame mirrorless, 24.2MP, phase AF" },
  { make: "Panasonic", name: "Lumix S5 IIX", description: "Full-frame mirrorless, 24.2MP, video features" },
  { make: "Panasonic", name: "Lumix S1H", description: "Full-frame mirrorless, 24.2MP, cinema camera" },
  { make: "Panasonic", name: "Lumix GH6", description: "Micro Four Thirds, 25.2MP, 5.7K video" },
  { make: "Panasonic", name: "Lumix GH5", description: "Micro Four Thirds, 20.3MP, video workhorse" },
  { make: "Panasonic", name: "Lumix G9", description: "Micro Four Thirds, 20.3MP, photo-centric" },

  # Leica (Premium cameras)
  { make: "Leica", name: "M11", description: "Rangefinder, 60MP, full-frame" },
  { make: "Leica", name: "Q3", description: "Fixed lens full-frame, 60MP, 28mm f/1.7" },
  { make: "Leica", name: "SL3", description: "Full-frame mirrorless, 60MP" },

  # Pentax/Ricoh
  { make: "Pentax", name: "K-3 Mark III", description: "APS-C DSLR, 25.7MP" },
  { make: "Ricoh", name: "GR IIIx", description: "APS-C compact, 24.2MP, 40mm equiv" },

  # Hasselblad
  { make: "Hasselblad", name: "X2D 100C", description: "Medium format mirrorless, 100MP" },
  { make: "Hasselblad", name: "907X 50C", description: "Medium format, 50MP, modular" },

  # Smartphone Cameras (Popular for mushroom photography)
  { make: "Apple", name: "iPhone 15 Pro Max", description: "Triple camera system, 48MP main" },
  { make: "Apple", name: "iPhone 14 Pro", description: "Triple camera system, 48MP main" },
  { make: "Apple", name: "iPhone 13 Pro", description: "Triple camera system, 12MP" },
  { make: "Samsung", name: "Galaxy S24 Ultra", description: "Quad camera, 200MP main" },
  { make: "Samsung", name: "Galaxy S23 Ultra", description: "Quad camera, 200MP main" },
  { make: "Google", name: "Pixel 8 Pro", description: "Triple camera, 50MP main, AI processing" }
]

camera_models = {}
camera_models_data.each do |model_data|
  model_key = "#{model_data[:make]}_#{model_data[:name]}"
  camera_models[model_key] = CameraModel.find_or_create_by!(name: model_data[:name]) do |model|
    model.description = model_data[:description]
  end
end

puts "Created #{camera_models.count} camera models"

# ============================================================================
# LENSES - Common lenses by mount/manufacturer
# ============================================================================
puts "Creating lenses..."

lenses_data = [
  # Canon RF Mount (Mirrorless)
  { make: "Canon", model: "RF 24-70mm f/2.8L IS USM", description: "Pro standard zoom" },
  { make: "Canon", model: "RF 70-200mm f/2.8L IS USM", description: "Pro telephoto zoom" },
  { make: "Canon", model: "RF 15-35mm f/2.8L IS USM", description: "Pro ultra-wide zoom" },
  { make: "Canon", model: "RF 50mm f/1.8 STM", description: "Affordable nifty fifty" },
  { make: "Canon", model: "RF 85mm f/1.2L USM", description: "Pro portrait lens" },
  { make: "Canon", model: "RF 100-500mm f/4.5-7.1L IS USM", description: "Wildlife telephoto" },
  { make: "Canon", model: "RF 35mm f/1.8 IS Macro STM", description: "Wide-angle macro" },

  # Canon EF Mount (DSLR)
  { make: "Canon", model: "EF 24-70mm f/2.8L II USM", description: "Pro standard zoom" },
  { make: "Canon", model: "EF 70-200mm f/2.8L IS III USM", description: "Pro telephoto zoom" },
  { make: "Canon", model: "EF 16-35mm f/2.8L III USM", description: "Pro ultra-wide zoom" },
  { make: "Canon", model: "EF 50mm f/1.8 STM", description: "Budget nifty fifty" },
  { make: "Canon", model: "EF 100mm f/2.8L IS USM Macro", description: "Pro macro lens" },

  # Nikon Z Mount (Mirrorless)
  { make: "Nikon", model: "NIKKOR Z 24-70mm f/2.8 S", description: "Pro standard zoom" },
  { make: "Nikon", model: "NIKKOR Z 70-200mm f/2.8 VR S", description: "Pro telephoto zoom" },
  { make: "Nikon", model: "NIKKOR Z 14-30mm f/4 S", description: "Ultra-wide zoom" },
  { make: "Nikon", model: "NIKKOR Z 50mm f/1.8 S", description: "Standard prime" },
  { make: "Nikon", model: "NIKKOR Z 85mm f/1.8 S", description: "Portrait prime" },
  { make: "Nikon", model: "NIKKOR Z MC 105mm f/2.8 VR S", description: "Macro lens" },

  # Nikon F Mount (DSLR)
  { make: "Nikon", model: "AF-S 24-70mm f/2.8E ED VR", description: "Pro standard zoom" },
  { make: "Nikon", model: "AF-S 70-200mm f/2.8E FL ED VR", description: "Pro telephoto zoom" },
  { make: "Nikon", model: "AF-S 50mm f/1.8G", description: "Budget nifty fifty" },
  { make: "Nikon", model: "AF-S VR 105mm f/2.8G IF-ED Micro", description: "Macro lens" },

  # Sony E Mount (Full-frame mirrorless)
  { make: "Sony", model: "FE 24-70mm f/2.8 GM II", description: "Pro standard zoom, 2nd gen" },
  { make: "Sony", model: "FE 70-200mm f/2.8 GM OSS II", description: "Pro telephoto zoom" },
  { make: "Sony", model: "FE 16-35mm f/2.8 GM", description: "Pro ultra-wide zoom" },
  { make: "Sony", model: "FE 50mm f/1.8", description: "Affordable prime" },
  { make: "Sony", model: "FE 85mm f/1.8", description: "Portrait prime" },
  { make: "Sony", model: "FE 90mm f/2.8 Macro G OSS", description: "Macro lens" },
  { make: "Sony", model: "FE 200-600mm f/5.6-6.3 G OSS", description: "Wildlife telephoto" },

  # Fujifilm X Mount
  { make: "Fujifilm", model: "XF 16-55mm f/2.8 R LM WR", description: "Pro standard zoom" },
  { make: "Fujifilm", model: "XF 50-140mm f/2.8 R LM OIS WR", description: "Pro telephoto zoom" },
  { make: "Fujifilm", model: "XF 35mm f/1.4 R", description: "Classic prime" },
  { make: "Fujifilm", model: "XF 56mm f/1.2 R", description: "Portrait prime" },
  { make: "Fujifilm", model: "XF 80mm f/2.8 R LM OIS WR Macro", description: "Macro lens" },
  { make: "Fujifilm", model: "XF 150-600mm f/5.6-8 R LM OIS WR", description: "Super telephoto" },

  # Olympus/OM System (Micro Four Thirds)
  { make: "Olympus", model: "M.Zuiko 12-40mm f/2.8 PRO", description: "Pro standard zoom" },
  { make: "Olympus", model: "M.Zuiko 40-150mm f/2.8 PRO", description: "Pro telephoto zoom" },
  { make: "Olympus", model: "M.Zuiko 25mm f/1.8", description: "Standard prime (50mm equiv)" },
  { make: "Olympus", model: "M.Zuiko 60mm f/2.8 Macro", description: "Macro lens" },
  { make: "OM System", model: "M.Zuiko 90mm f/3.5 Macro IS PRO", description: "Pro macro lens" },

  # Panasonic (Micro Four Thirds and L Mount)
  { make: "Panasonic", model: "Lumix S 24-70mm f/2.8", description: "L-mount standard zoom" },
  { make: "Panasonic", model: "Lumix S 70-200mm f/2.8", description: "L-mount telephoto zoom" },
  { make: "Panasonic", model: "Leica DG 12-60mm f/2.8-4", description: "MFT standard zoom" },
  { make: "Panasonic", model: "Leica DG 25mm f/1.4", description: "MFT prime" },

  # Third-party manufacturers (Sigma, Tamron, etc.)
  { make: "Sigma", model: "24-70mm f/2.8 DG DN Art", description: "For Sony E/L-mount" },
  { make: "Sigma", model: "85mm f/1.4 DG DN Art", description: "Portrait prime for mirrorless" },
  { make: "Sigma", model: "105mm f/2.8 DG DN Macro Art", description: "Macro for mirrorless" },
  { make: "Tamron", model: "28-75mm f/2.8 Di III VXD G2", description: "For Sony E-mount" },
  { make: "Tamron", model: "35-150mm f/2-2.8 Di III VXD", description: "Versatile zoom for Sony" },
  { make: "Tamron", model: "90mm f/2.8 Di III Macro VXD", description: "Macro for Sony E-mount" },
  { make: "Tokina", model: "atx-m 85mm f/1.8 FE", description: "Portrait lens for Sony E" }
]

lenses_data.each do |lens_data|
  Lens.find_or_create_by!(make: lens_data[:make], model: lens_data[:model]) do |lens|
    lens.description = lens_data[:description]
  end
end

puts "Created #{Lens.count} lenses"

puts "Camera equipment seeding complete!"
puts "Summary:"
puts "  - #{CameraMake.count} camera makes"
puts "  - #{CameraModel.count} camera models"
puts "  - #{Lens.count} lenses"
