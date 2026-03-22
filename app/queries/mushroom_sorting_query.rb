# frozen_string_literal: true

class MushroomSortingQuery
  def self.by_genus_and_color(scope = Mushroom.all)
    primary_genus_sql =
      GenusMushroom
        .joins(:genus)
        .where(is_primary: true)
        .select("genus_mushrooms.mushroom_id, genera.name AS primary_genus_name")
        .to_sql

    cover_image_sql =
      ImageMushroom
        .select("mushroom_id, MIN(id) AS cover_image_id")
        .group(:mushroom_id)
        .to_sql

    scope
      .joins("LEFT JOIN (#{primary_genus_sql}) primary_genera ON primary_genera.mushroom_id = mushrooms.id")
      .joins("LEFT JOIN (#{cover_image_sql}) cover_images ON cover_images.mushroom_id = mushrooms.id")
      .joins("LEFT JOIN image_mushrooms cover_image ON cover_image.id = cover_images.cover_image_id")
      .order(
        Arel.sql(
          "primary_genera.primary_genus_name IS NULL, " \
          "primary_genera.primary_genus_name ASC, " \
          "cover_image.dominant_hue IS NULL, " \
          "cover_image.dominant_hue ASC, " \
          "mushrooms.id ASC"
        )
      )
  end
end
