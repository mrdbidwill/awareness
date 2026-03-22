module ColorsHelper
  def color_thumb(color_id, size: 24, extra_classes: "")
    image_tag "AMS_colors/banner_50x50/banner_#{color_id}.jpg",
              alt: "Color #{color_id}",
              class: "rounded border",
              size: "#{size}x#{size}"
  end
end
