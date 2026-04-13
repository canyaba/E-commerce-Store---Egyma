# frozen_string_literal: true

module CatalogHelper
  CATALOG_FILTER_OPTIONS = [
    ['All products', nil],
    ['New this week', 'new'],
    ['Recently updated', 'recently_updated']
  ].freeze

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

  def catalog_filter_options
    CATALOG_FILTER_OPTIONS
  end

  def catalog_filter_path(path:, filter:, base_params: {})
    query_params = base_params.compact_blank
    query_params[:filter] = filter if filter.present?

    return path if query_params.empty?

    "#{path}?#{query_params.to_query}"
  end

  def selected_catalog_filter
    params[:filter].presence
  end
end
