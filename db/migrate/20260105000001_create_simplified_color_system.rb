# frozen_string_literal: true

# Migration to create a simplified hierarchical color system
# Replaces the 50 AMS colors with 27 organized, visually distinct colors
# grouped into 9 color families (White/Gray/Black, Brown, Red, Orange, Yellow, Green, Blue, Purple, Special)
class CreateSimplifiedColorSystem < ActiveRecord::Migration[8.0]
  def up
    # Add new columns for the hierarchical system
    add_column :colors, :color_family, :string unless column_exists?(:colors, :color_family)
    add_column :colors, :color_variant, :string unless column_exists?(:colors, :color_variant)
    add_column :colors, :display_order, :integer unless column_exists?(:colors, :display_order)
    add_column :colors, :is_simplified, :boolean, default: false unless column_exists?(:colors, :is_simplified)

    # Mark existing 50 colors as legacy (not simplified)
    execute "UPDATE colors SET is_simplified = false WHERE id <= 50"

    # Insert new simplified color system (IDs 101-127 to avoid conflicts)
    simplified_colors = [
      # WHITE/GRAY/BLACK FAMILY (101-103)
      { id: 101, latin_name: "Albus Simplex", common_name: "White", color_family: "Neutral", color_variant: "Light",
        hex: "#FFFFFF", r_val: 255, g_val: 255, b_val: 255, display_order: 1 },
      { id: 102, latin_name: "Griseus Simplex", common_name: "Gray", color_family: "Neutral", color_variant: "Medium",
        hex: "#808080", r_val: 128, g_val: 128, b_val: 128, display_order: 2 },
      { id: 103, latin_name: "Black Simplex", common_name: "Black", color_family: "Neutral", color_variant: "Dark",
        hex: "#000000", r_val: 0, g_val: 0, b_val: 0, display_order: 3 },

      # BROWN FAMILY (104-106)
      { id: 104, latin_name: "Brunneus Dilutus", common_name: "Light Brown", color_family: "Brown", color_variant: "Light",
        hex: "#D2B48C", r_val: 210, g_val: 180, b_val: 140, display_order: 4 },
      { id: 105, latin_name: "Brunneus", common_name: "Brown", color_family: "Brown", color_variant: "Medium",
        hex: "#8B4513", r_val: 139, g_val: 69, b_val: 19, display_order: 5 },
      { id: 106, latin_name: "Brunneus Obscurus", common_name: "Dark Brown", color_family: "Brown", color_variant: "Dark",
        hex: "#3E2723", r_val: 62, g_val: 39, b_val: 35, display_order: 6 },

      # RED FAMILY (107-109)
      { id: 107, latin_name: "Roseus Simplex", common_name: "Pink", color_family: "Red", color_variant: "Light",
        hex: "#FFB6C1", r_val: 255, g_val: 182, b_val: 193, display_order: 7 },
      { id: 108, latin_name: "Ruber Simplex", common_name: "Red", color_family: "Red", color_variant: "Medium",
        hex: "#DC143C", r_val: 220, g_val: 20, b_val: 60, display_order: 8 },
      { id: 109, latin_name: "Ruber Obscurus Simplex", common_name: "Dark Red", color_family: "Red", color_variant: "Dark",
        hex: "#8B0000", r_val: 139, g_val: 0, b_val: 0, display_order: 9 },

      # ORANGE FAMILY (110-112)
      { id: 110, latin_name: "Aurantiacus Dilutus Simplex", common_name: "Light Orange", color_family: "Orange", color_variant: "Light",
        hex: "#FFD1A4", r_val: 255, g_val: 209, b_val: 164, display_order: 10 },
      { id: 111, latin_name: "Aurantiacus Simplex", common_name: "Orange", color_family: "Orange", color_variant: "Medium",
        hex: "#FF8C00", r_val: 255, g_val: 140, b_val: 0, display_order: 11 },
      { id: 112, latin_name: "Aurantiacus Obscurus Simplex", common_name: "Burnt Orange", color_family: "Orange", color_variant: "Dark",
        hex: "#CC5500", r_val: 204, g_val: 85, b_val: 0, display_order: 12 },

      # YELLOW FAMILY (113-115)
      { id: 113, latin_name: "Flavus Pallidus Simplex", common_name: "Pale Yellow", color_family: "Yellow", color_variant: "Light",
        hex: "#FFFFCC", r_val: 255, g_val: 255, b_val: 204, display_order: 13 },
      { id: 114, latin_name: "Flavus Simplex", common_name: "Yellow", color_family: "Yellow", color_variant: "Medium",
        hex: "#FFD700", r_val: 255, g_val: 215, b_val: 0, display_order: 14 },
      { id: 115, latin_name: "Olivaceus Simplex", common_name: "Olive Yellow", color_family: "Yellow", color_variant: "Dark",
        hex: "#808000", r_val: 128, g_val: 128, b_val: 0, display_order: 15 },

      # GREEN FAMILY (116-118)
      { id: 116, latin_name: "Viridis Dilutus Simplex", common_name: "Light Green", color_family: "Green", color_variant: "Light",
        hex: "#90EE90", r_val: 144, g_val: 238, b_val: 144, display_order: 16 },
      { id: 117, latin_name: "Viridis Simplex", common_name: "Green", color_family: "Green", color_variant: "Medium",
        hex: "#228B22", r_val: 34, g_val: 139, b_val: 34, display_order: 17 },
      { id: 118, latin_name: "Viridis Obscurus Simplex", common_name: "Dark Green", color_family: "Green", color_variant: "Dark",
        hex: "#006400", r_val: 0, g_val: 100, b_val: 0, display_order: 18 },

      # BLUE FAMILY (119-121)
      { id: 119, latin_name: "Caeruleus Dilutus Simplex", common_name: "Light Blue", color_family: "Blue", color_variant: "Light",
        hex: "#ADD8E6", r_val: 173, g_val: 216, b_val: 230, display_order: 19 },
      { id: 120, latin_name: "Caeruleus Simplex", common_name: "Blue", color_family: "Blue", color_variant: "Medium",
        hex: "#0000FF", r_val: 0, g_val: 0, b_val: 255, display_order: 20 },
      { id: 121, latin_name: "Caeruleus Obscurus Simplex", common_name: "Dark Blue", color_family: "Blue", color_variant: "Dark",
        hex: "#00008B", r_val: 0, g_val: 0, b_val: 139, display_order: 21 },

      # PURPLE FAMILY (122-124)
      { id: 122, latin_name: "Violaceus Dilutus Simplex", common_name: "Lilac", color_family: "Purple", color_variant: "Light",
        hex: "#DDA0DD", r_val: 221, g_val: 160, b_val: 221, display_order: 22 },
      { id: 123, latin_name: "Violaceus Simplex", common_name: "Purple", color_family: "Purple", color_variant: "Medium",
        hex: "#800080", r_val: 128, g_val: 0, b_val: 128, display_order: 23 },
      { id: 124, latin_name: "Violaceus Obscurus Simplex", common_name: "Dark Purple", color_family: "Purple", color_variant: "Dark",
        hex: "#4B0082", r_val: 75, g_val: 0, b_val: 130, display_order: 24 },

      # SPECIAL CATEGORY (125-127)
      { id: 125, latin_name: "Metallicus", common_name: "Metallic", color_family: "Special", color_variant: "Metallic",
        hex: "#C0C0C0", r_val: 192, g_val: 192, b_val: 192, display_order: 25 },
      { id: 126, latin_name: "Iridescens", common_name: "Iridescent", color_family: "Special", color_variant: "Iridescent",
        hex: "#9370DB", r_val: 147, g_val: 112, b_val: 219, display_order: 26 },
      { id: 127, latin_name: "Multicolor", common_name: "Multi-colored", color_family: "Special", color_variant: "Multi",
        hex: "#FF6347", r_val: 255, g_val: 99, b_val: 71, display_order: 27 }
    ]

    simplified_colors.each do |color|
      execute <<-SQL
        INSERT INTO colors (
          id, latin_name, common_name, color_family, color_variant,
          hex, r_val, g_val, b_val, display_order, is_simplified,
          sequence, color_group, image_file_address, created_at, updated_at
        ) VALUES (
          #{color[:id]},
          '#{color[:latin_name]}',
          '#{color[:common_name]}',
          '#{color[:color_family]}',
          '#{color[:color_variant]}',
          '#{color[:hex]}',
          #{color[:r_val]},
          #{color[:g_val]},
          #{color[:b_val]},
          #{color[:display_order]},
          true,
          #{color[:display_order]},
          #{(color[:display_order] - 1) / 3 + 1},
          'simplified_colors/color_#{color[:id]}.png',
          NOW(),
          NOW()
        )
      SQL
    end

    # Add indexes for better query performance
    add_index :colors, :color_family unless index_exists?(:colors, :color_family)
    add_index :colors, :is_simplified unless index_exists?(:colors, :is_simplified)
    add_index :colors, :display_order unless index_exists?(:colors, :display_order)
  end

  def down
    # Remove simplified colors
    execute "DELETE FROM colors WHERE id BETWEEN 101 AND 127"

    # Remove indexes
    remove_index :colors, :color_family if index_exists?(:colors, :color_family)
    remove_index :colors, :is_simplified if index_exists?(:colors, :is_simplified)
    remove_index :colors, :display_order if index_exists?(:colors, :display_order)

    # Remove columns
    remove_column :colors, :color_family if column_exists?(:colors, :color_family)
    remove_column :colors, :color_variant if column_exists?(:colors, :color_variant)
    remove_column :colors, :display_order if column_exists?(:colors, :display_order)
    remove_column :colors, :is_simplified if column_exists?(:colors, :is_simplified)
  end
end
