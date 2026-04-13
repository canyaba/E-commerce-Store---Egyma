# frozen_string_literal: true

module CatalogHelper
  PRODUCT_IMAGE_VARIANTS = {
    admin_thumb: { resize_to_fill: [120, 120] },
    card: { resize_to_fill: [640, 420] },
    detail: { resize_to_limit: [960, 720] }
  }.freeze

  CATALOG_FILTER_OPTIONS = [
    ['All products', nil],
    ['New this week', 'new'],
    ['Recently updated', 'recently_updated']
  ].freeze

  def product_price(product)
    number_to_currency(product.price)
  end

  def product_image_or_placeholder(product, variant:, css_class:, size:, loading: 'lazy')
    return product_variant_image(product, variant:, css_class:, size:, loading:) if product.image.attached?

    product_image_placeholder(css_class:, height: size.last)
  end

  private

  def product_variant_image(product, variant:, css_class:, size:, loading:)
    width, height = size

    image_tag(
      product.image.variant(PRODUCT_IMAGE_VARIANTS.fetch(variant)),
      alt: product.title,
      class: css_class,
      width: width,
      height: height,
      loading: loading,
      decoding: 'async'
    )
  end

  def product_image_placeholder(css_class:, height:)
    content_tag(
      :div,
      'No image uploaded',
      class: "#{css_class} product-image-placeholder",
      style: "min-height: #{height}px;"
    )
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
