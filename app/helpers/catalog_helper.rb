# frozen_string_literal: true

module CatalogHelper
  def product_price(product)
    number_to_currency(product.price)
  end

  def product_image_or_placeholder(product, size:, css_class:)
    if product.image.attached?
      image_tag(url_for(product.image), alt: product.title, class: css_class, size: size)
    else
      content_tag(:div, 'No image uploaded', class: "#{css_class} product-image-placeholder")
    end
  end
end
