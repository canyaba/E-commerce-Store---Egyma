# frozen_string_literal: true

class Cart
  SESSION_KEY = :cart

  Item = Struct.new(:product, :quantity) do
    def total_price
      product.price * quantity
    end
  end

  def initialize(session)
    @session = session
    @contents = normalize_contents(session[SESSION_KEY])
  end

  def add_item(product_id, quantity)
    quantity = normalize_quantity(quantity)
    return nil if quantity < 1
    return nil unless Product.active_catalog.exists?(product_id)

    @contents[product_id.to_i] = @contents.fetch(product_id.to_i, 0) + quantity
    persist!
    @contents[product_id.to_i]
  end

  def update_item(product_id, quantity)
    product_id = product_id.to_i
    quantity = normalize_quantity(quantity)
    return nil unless @contents.key?(product_id)
    return nil if quantity < 1

    @contents[product_id] = quantity
    persist!
    @contents[product_id]
  end

  def remove_item(product_id)
    removed = @contents.delete(product_id.to_i)
    persist!
    removed
  end

  def items
    products_by_id = Product.active_catalog
                            .with_attached_image
                            .includes(:categories)
                            .where(id: @contents.keys)
                            .index_by(&:id)

    @contents.filter_map do |product_id, quantity|
      product = products_by_id[product_id]
      Item.new(product, quantity) if product.present?
    end
  end

  def count
    @contents.values.sum
  end

  def empty?
    count.zero?
  end

  def subtotal
    items.sum(&:total_price)
  end

  def clear!
    @contents = {}
    persist!
  end

  private

  def normalize_contents(contents)
    contents.to_h.each_with_object({}) do |(product_id, quantity), normalized|
      quantity = normalize_quantity(quantity)
      next if quantity < 1

      normalized[product_id.to_i] = quantity
    end
  end

  def normalize_quantity(quantity)
    quantity.to_i
  end

  def persist!
    @session[SESSION_KEY] = @contents.transform_keys(&:to_s)
  end
end
