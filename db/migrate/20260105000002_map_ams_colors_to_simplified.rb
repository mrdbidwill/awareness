# frozen_string_literal: true

# Maps existing 50 AMS colors to the new simplified 27-color system
# Adds a mapping column so existing color selections can be preserved
# while providing a path to migrate to the simplified system
class MapAmsColorsToSimplified < ActiveRecord::Migration[8.0]
  def up
    # Add mapping column
    add_column :colors, :simplified_color_id, :integer unless column_exists?(:colors, :simplified_color_id)
    add_index :colors, :simplified_color_id unless index_exists?(:colors, :simplified_color_id)

    # Mapping based on color analysis of the 50 AMS colors
    # Each AMS color is mapped to the closest simplified color
    mappings = {
      # WHITE/GRAY/BLACK
      1 => 101,  # Albus (White) -> White
      2 => 102,  # Griseus (Grullo) -> Gray
      3 => 102,  # Murinus (Shadow) -> Gray
      4 => 103,  # Ater (Dark Lava) -> Black
      5 => 103,  # Black -> Black
      38 => 102, # Glaucus (Pastel Gray) -> Gray
      43 => 102, # Caesius (Pale Silver) -> Gray
      44 => 102, # Plumbeus (Battleship Gray) -> Gray

      # BROWNS
      6 => 104,  # Fumosus (Pastel Brown) -> Light Brown
      7 => 104,  # Avellaneus (Cafe au lait) -> Light Brown
      8 => 105,  # Isabellinus (Ruddy Brown) -> Brown
      9 => 105,  # Umbrinus (Sepia) -> Brown
      10 => 106, # Castaneus (Caput Mortuum) -> Dark Brown
      11 => 105, # Fuligineus (Zinnwaldite Brown) -> Brown
      20 => 106, # Badius (Caput Mortuum also) -> Dark Brown
      32 => 105, # Fulvus (Brown Traditional) -> Brown
      39 => 106, # Olivaceus (Dark Brown) -> Dark Brown

      # REDS & PURPLES
      12 => 109, # Atropurpureus (Bulgarian Rose) -> Dark Red
      13 => 108, # Purpureus (OU Crimson Red) -> Red
      14 => 108, # Ruber (Rosso Corsa) -> Red
      15 => 108, # Miniatus (Coquelicot) -> Red
      16 => 111, # Incarnatus (Deep Carrot Orange) -> Orange
      17 => 107, # Roseus (Light Salmon) -> Pink
      46 => 124, # Atro-violaceus (Caput Mortuum Also) -> Dark Purple
      47 => 123, # Violaceus (French Lilac) -> Purple
      48 => 122, # Lilacinus (Puce) -> Lilac
      49 => 122, # Lividus (Old Mauve) -> Lilac
      50 => 109, # Vinosus (Bulgarian Rose Also) -> Dark Red

      # ORANGES
      18 => 111, # Testaceus (Flame) -> Orange
      19 => 111, # Latericius (Sienna) -> Orange
      21 => 111, # Aurantiacus (Safety Orange) -> Orange
      31 => 112, # Ferrunineus (Burnt Orange) -> Burnt Orange

      # YELLOWS
      22 => 114, # Luteus (Tangerine) -> Yellow
      23 => 114, # Flavus (UCLA Gold) -> Yellow
      24 => 114, # Citrinus (Meat brown) -> Yellow
      25 => 113, # Sulphureus (Straw) -> Pale Yellow
      26 => 113, # Stramineus (Pale Gold) -> Pale Yellow
      27 => 113, # Cremeus (Pale Gold also) -> Pale Yellow
      28 => 114, # Ochroleucus (Topaz) -> Yellow
      29 => 110, # Ochraceus (Pastel Orange) -> Light Orange
      30 => 114, # Melleus (Indian Yellow) -> Yellow

      # GREENS
      33 => 117, # Flavo-virens (Brass) -> Green
      34 => 118, # Atro-virens (Myrtle) -> Dark Green
      35 => 117, # Viridis (Fern Green) -> Green
      36 => 117, # Prasinus (Fern Green) -> Green
      37 => 102, # Aerugineus (Slate Gray) -> Gray
      45 => 118, # Ardesiacus (Rifle Green) -> Dark Green

      # BLUES
      40 => 121, # Atro-cyaneus (Oxford Blue) -> Dark Blue
      41 => 120, # Cyaneus (Royal Blue) -> Blue
      42 => 119  # Caeruleus (Moonstone Blue) -> Light Blue
    }

    mappings.each do |ams_id, simplified_id|
      execute "UPDATE colors SET simplified_color_id = #{simplified_id} WHERE id = #{ams_id}"
    end

    say "Mapped #{mappings.size} AMS colors to simplified color system"
  end

  def down
    remove_index :colors, :simplified_color_id if index_exists?(:colors, :simplified_color_id)
    remove_column :colors, :simplified_color_id if column_exists?(:colors, :simplified_color_id)
  end
end
